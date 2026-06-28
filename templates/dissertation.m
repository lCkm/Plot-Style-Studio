function dissertation(ctx)

fig = [];
ax  = [];

% 用 FigS 传入的 ctx 接口获取目标图窗和坐标轴
if nargin >= 1 && isstruct(ctx)
    try
        fig = ctx.getFigure();          % ← 正确的接口
    catch
    end
    try
        axList = ctx.getAxes(fig);
        if ~isempty(axList)
            ax = axList(1);             % 取第一个坐标轴
        end
    catch
    end
end

% 兜底
if isempty(fig) || ~isgraphics(fig), fig = gcf; end
if isempty(ax)  || ~isgraphics(ax),  ax  = gca; end

% 标签与标题字号
set(get(ax, 'XLabel'), 'FontSize', 26.4, 'FontWeight', 'normal');
set(get(ax, 'YLabel'), 'FontSize', 26.4, 'FontWeight', 'normal');
set(get(ax, 'ZLabel'), 'FontSize', 26.4, 'FontWeight', 'normal');
set(get(ax, 'Title'),  'FontSize', 26.4, 'FontWeight', 'normal');
set(ax, 'FontSize', 24);

% 图例样式
lgd = findobj(fig, 'Type', 'legend');
if ~isempty(lgd)
    set(lgd, 'FontSize', 24, 'EdgeColor', 'none', 'Color', 'none');
end

% 坐标轴位置（仅单图时调整）
axList = fb_util('targetaxes', fig);
if numel(axList) == 1
    drawnow;
    set(ax, 'Units', 'normalized');
    set(ax, 'LooseInset', [0 0 0 0]);
    set(ax, 'OuterPosition', [0 0 1 1]);
    drawnow;
end
end