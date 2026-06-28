function [defs, names, keys] = common_functions()
% 常用函数模板（GUI自动读取版）
% ====================
% 本文件放在 templates 文件夹中，GUI 会自动读取 defs / names / keys。
%
% callback 函数统一接收 ctx 结构体，常用字段：
%   ctx.getFigure()        - 获取当前目标 Fig
%   ctx.getAxes(fig)       - 获取目标 Fig 的坐标轴
%   ctx.toast(msg)         - GUI 状态栏提示
%   ctx.bringToFront(fig)  - 将目标 Fig 置顶

% ==================== 常用函数定义 ====================

names.gradientcolor = 'GradientColor  临时渐变色';
defs.gradientcolor = struct(...
    'name', names.gradientcolor, ...
    'description', '输入 2 个或多个颜色节点，生成临时渐变色；可同时适配线图、柱图、散点、曲面、云图等。', ...
    'callback', @runGradientColor);

names.legendtrans = 'LegendTrans  图例顺序';
defs.legendtrans = struct(...
    'name', names.legendtrans, ...
    'description', '输入图例新顺序，例如 [2 1 3]，调整当前图窗图例顺序。', ...
    'callback', @runLegendTrans);

% ==================== 自动排序 ====================
keys = fieldnames(defs);
end

%% ==================== GradientColor ====================
function runGradientColor(ctx)
    prompt = { ...
        '颜色节点，支持 #RRGGBB 或 RGB 矩阵：', ...
        '渐变数量 n：', ...
        '应用模式：auto / all / objects / colormap'};
    def = {'#2166AC,#FFFFFF,#B2182B', '256', 'auto'};
    answ = inputdlg(prompt, 'GradientColor 临时渐变色', [1 72; 1 72; 1 72], def);
    if isempty(answ), return; end

    try
        colors = parseColorInput(answ{1});
        n = round(str2double(strtrim(answ{2})));
        if isnan(n) || n < 2
            n = 256;
        end
        mode = lower(strtrim(answ{3}));
        if isempty(mode)
            mode = 'auto';
        end
        if ~ismember(mode, {'auto', 'all', 'objects', 'colormap'})
            mode = 'auto';
        end
        cmap = buildGradientColormap(colors, n);
    catch ME
        ctx.toast(['渐变色创建失败: ' ME.message]);
        return;
    end

    f = ctx.getFigure();
    if isempty(f) || ~isgraphics(f, 'figure')
        ctx.toast('没有找到可应用渐变色的 Fig 图窗');
        return;
    end

    try
        axs = ctx.getAxes(f);
    catch
        axs = findall(f, 'Type', 'axes');
    end

    if isempty(axs)
        ctx.toast('当前图窗没有可用坐标轴');
        return;
    end

    try
        nObj = 0;
        nMap = 0;
        for ai = 1:numel(axs)
            ax = axs(ai);
            if ~isgraphics(ax, 'axes'), continue; end
            [nObj_i, nMap_i] = applyGradientToAxes(ax, cmap, mode);
            nObj = nObj + nObj_i;
            nMap = nMap + nMap_i;
        end

        % Figure 级 colormap 也同步设置，兼容旧版本 MATLAB 或部分 colorbar。
        try colormap(f, cmap); catch, end
        assignin('base', 'FBV4_custom_colormap', cmap);
        ctx.bringToFront(f);
        ctx.toast(sprintf('已应用渐变色：普通对象 %d 个，色图坐标轴 %d 个；变量 FBV4_custom_colormap 已保存', nObj, nMap));
    catch ME
        ctx.toast(['渐变色应用失败: ' ME.message]);
    end
end

function [nObj, nMap] = applyGradientToAxes(ax, cmap, mode)
    nObj = 0;
    nMap = 0;

    useColormap = any(strcmp(mode, {'auto', 'all', 'colormap'}));
    useObjects  = any(strcmp(mode, {'auto', 'all', 'objects'}));

    if useColormap && axesHasColormapDataLocal(ax)
        try
            colormap(ax, cmap);
        catch
            try colormap(cmap); catch, end
        end
        refreshColorbarLocal(ax);
        nMap = nMap + 1;
    elseif strcmp(mode, 'colormap')
        % 用户明确选择 colormap 时，即使没有云图对象，也设置当前轴 colormap。
        try
            colormap(ax, cmap);
            nMap = nMap + 1;
        catch
        end
    end

    if useObjects
        objs = collectOrdinaryGraphicObjects(ax);
        if isempty(objs), return; end
        objColors = sampleColorsFromCmap(cmap, numel(objs));
        for oi = 1:numel(objs)
            try
                if applySingleObjectColor(objs(oi), objColors(oi, :), cmap)
                    nObj = nObj + 1;
                end
            catch
            end
        end
    end
end

function objs = collectOrdinaryGraphicObjects(ax)
    objs = gobjects(0);
    try
        ch = flipud(get(ax, 'Children'));
    catch
        return;
    end

    validTypes = {'line', 'errorbar', 'stair', 'bar', 'scatter', 'patch', 'area', 'histogram', 'stem'};
    for k = 1:numel(ch)
        h = ch(k);
        if ~isgraphics(h), continue; end
        try
            tag = lower(get(h, 'Tag'));
            if contains(tag, 'fbv2_inset') || contains(tag, 'fbv2_temp')
                continue;
            end
        catch
        end
        try
            typ = lower(get(h, 'Type'));
        catch
            typ = '';
        end

        if ismember(typ, validTypes) || hasAnyColorProperty(h)
            % image/surface/contour 由 colormap 处理，不在这里强行改颜色。
            if ismember(typ, {'image', 'surface', 'contour'})
                continue;
            end
            objs(end+1, 1) = h; %#ok<AGROW>
        end
    end
end

function tf = hasAnyColorProperty(h)
    tf = false;
    props = {'Color', 'FaceColor', 'EdgeColor', 'CData'};
    for i = 1:numel(props)
        if isprop(h, props{i})
            tf = true;
            return;
        end
    end
end

function changed = applySingleObjectColor(h, c, cmap)
    changed = false;
    if ~isgraphics(h), return; end
    try
        typ = lower(get(h, 'Type'));
    catch
        typ = '';
    end

    switch typ
        case {'line', 'errorbar', 'stair', 'stem'}
            changed = setIfProp(h, 'Color', c) || changed;
            setIfProp(h, 'MarkerEdgeColor', c);
            % 如果原来是空心标记，则不强行填充；否则填充为同色。
            try
                mfc = get(h, 'MarkerFaceColor');
                if ~(ischar(mfc) && strcmpi(mfc, 'none'))
                    setIfProp(h, 'MarkerFaceColor', c);
                end
            catch
            end

        case 'scatter'
            % 散点图：如果是多点散点，使用真正的点级渐变；否则使用单色。
            try
                xd = get(h, 'XData');
                nPoint = numel(xd);
            catch
                nPoint = 1;
            end
            if nPoint > 1
                C = sampleColorsFromCmap(cmap, nPoint);
                changed = setIfProp(h, 'CData', C) || changed;
            else
                changed = setIfProp(h, 'CData', c) || changed;
            end
            setIfProp(h, 'MarkerEdgeColor', 'flat');
            setIfProp(h, 'MarkerFaceColor', 'flat');

        case 'bar'
            changed = setIfProp(h, 'FaceColor', c) || changed;
            setIfProp(h, 'EdgeColor', [0.15 0.15 0.15]);

        case {'patch', 'area'}
            if hasMappedCDataLocal(h)
                % 有数据映射的 patch/area 不破坏 CData，只让 colormap 控制。
                ax = ancestor(h, 'axes');
                try colormap(ax, cmap); catch, end
            else
                changed = setIfProp(h, 'FaceColor', c) || changed;
                setIfProp(h, 'EdgeColor', [0.15 0.15 0.15]);
            end

        case 'histogram'
            changed = setIfProp(h, 'FaceColor', c) || changed;
            setIfProp(h, 'EdgeColor', [0.15 0.15 0.15]);

        otherwise
            % 兜底：对象只要有 Color / FaceColor / CData，就尽量设置。
            changed = setIfProp(h, 'Color', c) || changed;
            changed = setIfProp(h, 'FaceColor', c) || changed;
            if ~changed
                changed = setIfProp(h, 'CData', c) || changed;
            end
    end
end

function ok = setIfProp(h, propName, val)
    ok = false;
    try
        if isprop(h, propName)
            set(h, propName, val);
            ok = true;
        end
    catch
    end
end

function C = sampleColorsFromCmap(cmap, n)
    n = max(1, round(n));
    if n == 1
        idx = round(size(cmap, 1) / 2);
    else
        idx = round(linspace(1, size(cmap, 1), n));
    end
    idx = max(1, min(size(cmap, 1), idx));
    C = cmap(idx, :);
end

function tf = axesHasColormapDataLocal(ax)
    tf = false;
    if ~isgraphics(ax, 'axes'), return; end
    children = findall(ax);
    for k = 1:numel(children)
        ch = children(k);
        if ~isgraphics(ch), continue; end
        try typ = lower(get(ch, 'Type')); catch, continue; end

        switch typ
            case 'image'
                if ~isTrueColorObjectLocal(ch)
                    tf = true; return;
                end
            case 'surface'
                if ~isTrueColorObjectLocal(ch)
                    tf = true; return;
                end
            case 'contour'
                tf = true; return;
            case {'scatter', 'patch'}
                if hasMappedCDataLocal(ch)
                    tf = true; return;
                end
        end
    end
end

function tf = hasMappedCDataLocal(ch)
    tf = false;
    try
        cd = get(ch, 'CData');
    catch
        return;
    end
    if isempty(cd) || ~isnumeric(cd), return; end

    % 单个 1×3 RGB 或 N×3 RGB 列表不算映射数据。
    if ismatrix(cd) && size(cd, 2) == 3 && all(cd(:) >= 0 & cd(:) <= 1)
        return;
    end
    tf = true;
end

function tf = isTrueColorObjectLocal(ch)
    tf = false;
    try
        cd = get(ch, 'CData');
    catch
        return;
    end
    if isempty(cd) || ~isnumeric(cd), return; end
    if ndims(cd) == 3 && size(cd, 3) == 3
        tf = true;
        return;
    end
    if ismatrix(cd) && size(cd, 2) == 3 && all(cd(:) >= 0 & cd(:) <= 1)
        tf = true;
    end
end

function refreshColorbarLocal(ax)
    try
        fig = ancestor(ax, 'figure');
        cbs = findall(fig, 'Type', 'colorbar');
        for i = 1:numel(cbs)
            try
                if isequal(cbs(i).Axes, ax)
                    drawnow limitrate;
                end
            catch
            end
        end
    catch
    end
end

function colors = parseColorInput(txt)
    txt = strtrim(txt);
    hexList = regexp(txt, '#[0-9A-Fa-f]{6}', 'match');
    if ~isempty(hexList)
        colors = zeros(numel(hexList), 3);
        for kk = 1:numel(hexList)
            colors(kk, :) = hexToRgb(hexList{kk});
        end
    else
        cleanTxt = regexprep(txt, '[\[\],;]', ' ');
        nums = sscanf(cleanTxt, '%f');
        if isempty(nums) || mod(numel(nums), 3) ~= 0
            error('颜色格式无效。示例: #2166AC,#FFFFFF,#B2182B 或 [33 102 172; 255 255 255; 178 24 43]');
        end
        colors = reshape(nums, 3, []).';
    end

    if size(colors, 1) < 2 || size(colors, 2) ~= 3
        error('至少需要 2 个颜色节点，且每个颜色必须包含 RGB 三个数值。');
    end
    if any(colors(:) > 1)
        colors = colors ./ 255;
    end
    colors = max(0, min(1, colors));
end

function rgb = hexToRgb(hexStr)
    hexStr = char(strtrim(hexStr));
    if numel(hexStr) ~= 7 || hexStr(1) ~= '#'
        error('HEX 颜色必须为 #RRGGBB 格式。');
    end
    rgb = [hex2dec(hexStr(2:3)), hex2dec(hexStr(4:5)), hex2dec(hexStr(6:7))] ./ 255;
end

function cmap = buildGradientColormap(colors, n)
    n = max(2, round(n));
    pos = linspace(0, 1, size(colors, 1));
    x = linspace(0, 1, n);
    cmap = [interp1(pos, colors(:, 1), x, 'linear')', ...
            interp1(pos, colors(:, 2), x, 'linear')', ...
            interp1(pos, colors(:, 3), x, 'linear')'];
    cmap = max(0, min(1, cmap));
end

%% ==================== LegendTrans ====================
function runLegendTrans(ctx)
    f = ctx.getFigure();
    if isempty(f) || ~isgraphics(f, 'figure')
        ctx.toast('没有找到可调整图例的 Fig 图窗');
        return;
    end

    axs = ctx.getAxes(f);
    if isempty(axs)
        ctx.toast('当前图窗没有可用坐标轴');
        return;
    end
    ax = axs(1);

    lgd = findobj(f, 'Type', 'Legend');
    if isempty(lgd)
        ctx.toast('当前图窗没有图例，请先创建 legend');
        return;
    end
    lgd = lgd(1);

    try
        labels = get(lgd, 'String');
        labels = cellstr(labels);
        nLabel = numel(labels);
    catch
        nLabel = 0;
    end
    if nLabel < 1
        ctx.toast('当前图例为空，无法调整顺序');
        return;
    end

    defaultOrder = mat2str(1:nLabel);
    prompt = {sprintf('当前图例共 %d 项，请输入新顺序：', nLabel)};
    answ = inputdlg(prompt, 'LegendTrans 图例顺序', [1 58], {defaultOrder});
    if isempty(answ), return; end

    try
        neworder = str2num(answ{1}); %#ok<ST2NM>
        if isempty(neworder) || numel(neworder) ~= nLabel || ...
                any(neworder < 1) || any(neworder > nLabel) || ...
                numel(unique(neworder)) ~= nLabel
            error('顺序必须包含 1 到 %d 的每个序号，且不能重复。', nLabel);
        end
        applyLegendOrder(ax, lgd, neworder);
        ctx.bringToFront(f);
        ctx.toast(['已调整图例顺序: ' mat2str(neworder)]);
    catch ME
        ctx.toast(['图例顺序调整失败: ' ME.message]);
    end
end

function hLeg = applyLegendOrder(ax, lgd, neworder)
    labels = cellstr(get(lgd, 'String'));
    try
        plots = lgd.PlotChildren;
        plots = plots(:);
    catch
        plots = flipud(get(ax, 'Children'));
        plots = plots(:);
    end

    isValid = arrayfun(@(h) isgraphics(h), plots);
    plots = plots(isValid);
    n = min(numel(labels), numel(plots));
    labels = labels(1:n);
    plots = plots(1:n);

    neworder = neworder(:).';
    if numel(neworder) ~= n || any(neworder < 1) || any(neworder > n) || ...
            numel(unique(neworder)) ~= n
        error('顺序必须包含 1 到 %d 的每个序号，且不能重复。', n);
    end

    try
        loc = get(lgd, 'Location');
    catch
        loc = 'best';
    end
    hLeg = legend(ax, plots(neworder), labels(neworder), 'Location', loc);
end
