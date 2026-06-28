function varargout = fb_util(action, varargin)
%FB_UTIL Shared utilities for Fig Best helper functions.
%
% This file centralizes figure/axes filtering and common axis styling so that
% GUI callbacks, presets, colors, fonts and plot wrappers use the same rules.

if nargin == 0 || isempty(action)
    error('fb_util:missingAction', 'Action is required.');
end

if isstring(action), action = char(action); end

% ---- 加密兼容：每次调用公共工具前，自动确认项目根目录和 templates 已加入路径 ----
initProjectPath(false);

switch lower(action)
    case {'initpath','initprojectpath','ensurepath'}
        varargout{1} = initProjectPath(true);
    case {'projectroot','rootdir'}
        P = initProjectPath(true);
        varargout{1} = P.rootDir;
    case {'templatedir','templatesdir','templates'}
        P = initProjectPath(true);
        varargout{1} = P.templateDir;
    case {'targetfigs','targetfigures'}
        varargout{1} = targetFigures();
    case {'isguifig','isguifigure'}
        varargout{1} = isGuiFigure(varargin{1});
    case {'targetaxes','dataaxes'}
        if nargin >= 2
            f = varargin{1};
        else
            f = gcf;
        end
        includeInset = false;
        if nargin >= 3
            includeInset = logical(varargin{2});
        end
        varargout{1} = targetAxes(f, includeInset);
    case {'mainaxes','sourceaxes'}
        if nargin >= 2
            f = varargin{1};
        else
            f = gcf;
        end
        varargout{1} = mainAxes(f);
    case {'isspecialaxes','isexcludedaxes'}
        includeInset = false;
        if nargin >= 3
            includeInset = logical(varargin{2});
        end
        varargout{1} = isSpecialAxes(varargin{1}, includeInset);
    case 'styleaxes'
        styleAxes(varargin{:});
    case 'setminorgrid'
        setMinorGrid(varargin{:});
    case 'safegettag'
        varargout{1} = safeGetTag(varargin{1});
    otherwise
        error('fb_util:unknownAction', 'Unknown action: %s', action);
end
end


function P = initProjectPath(showWarn)
%INITPROJECTPATH 初始化项目路径与 templates 路径
% 性能优化版：首次搜索后缓存路径，避免每次按钮回调都扫描 MATLAB path 并 rehash。

persistent cachedP didRehash

if nargin < 1
    showWarn = false;
end

if ~isempty(cachedP) && isstruct(cachedP)
    P = cachedP;
    if showWarn && (isempty(P.templateDir) || ~exist(P.templateDir, 'dir'))
        warning('fb_util:missingTemplates', '未找到 templates 文件夹。请确认 templates 与 FigS.p/fb_util.p 位于同一项目目录下，或已加入 MATLAB 路径。');
    end
    return;
end

requiredFiles = {'preset_styles.m', 'color_schemes.m', 'user_styles.m', 'common_functions.m'};
[rootDir, templateDir] = findTemplateDir(requiredFiles);

if isempty(rootDir) || ~exist(rootDir, 'dir')
    rootDir = pwd;
end

if exist(rootDir, 'dir') && isempty(strfind(path, rootDir))
    addpath(rootDir, '-begin');
end

if ~isempty(templateDir) && exist(templateDir, 'dir')
    if isempty(strfind(path, templateDir))
        addpath(templateDir, '-begin');
    end
elseif showWarn
    warning('fb_util:missingTemplates', '未找到 templates 文件夹。请确认 templates 与 FigS.p/fb_util.p 位于同一项目目录下，或已加入 MATLAB 路径。');
end

% rehash 很慢，只在首次真正新增路径后执行一次。
if isempty(didRehash) || ~didRehash
    try rehash; catch, end
    didRehash = true;
end

P = struct();
P.rootDir = rootDir;
P.templateDir = templateDir;
cachedP = P;
end

function [rootDir, templateDir] = findTemplateDir(requiredFiles)
rootDir = '';
templateDir = '';
candidates = {};

% 1) 当前调用栈位置。
try
    st = dbstack('-completenames');
    for ii = 1:numel(st)
        if isfield(st(ii), 'file') && ~isempty(st(ii).file)
            candidates{end+1} = fileparts(st(ii).file); %#ok<AGROW>
        end
    end
catch
end

% 2) 相关函数所在位置。
names = {'fb_util', 'FigS', 'fb_apply', 'fb_color', 'fb_export', 'fb_inset'};
for ii = 1:numel(names)
    try
        f = which(names{ii});
        if ~isempty(f)
            candidates{end+1} = fileparts(f); %#ok<AGROW>
        end
    catch
    end
end

% 3) 模板函数如果已可见，反推其目录。
for ii = 1:numel(requiredFiles)
    [~, nm] = fileparts(requiredFiles{ii});
    try
        f = which(nm);
        if ~isempty(f)
            candidates{end+1} = fileparts(f); %#ok<AGROW>
        end
    catch
    end
end

% 4) 当前目录和 MATLAB path。
candidates{end+1} = pwd;
try
    pList = strsplit(path, pathsep);
    candidates = [candidates, pList]; %#ok<AGROW>
catch
end

candidates = candidates(~cellfun('isempty', candidates));
candidates = unique(candidates, 'stable');

for ii = 1:numel(candidates)
    base = candidates{ii};
    if ~exist(base, 'dir'), continue; end
    cur = base;
    for jj = 1:6
        if isTemplatesDir(cur, requiredFiles)
            templateDir = cur;
            rootDir = fileparts(cur);
            return;
        end
        tdir = fullfile(cur, 'templates');
        if isTemplatesDir(tdir, requiredFiles)
            templateDir = tdir;
            rootDir = cur;
            return;
        end
        parent = fileparts(cur);
        if isempty(parent) || strcmp(parent, cur)
            break;
        end
        cur = parent;
    end
end

try
    f = which('fb_util');
    if ~isempty(f)
        rootDir = fileparts(f);
        templateDir = fullfile(rootDir, 'templates');
    end
catch
end
end

function tf = isTemplatesDir(tdir, requiredFiles)
tf = false;
if isempty(tdir) || ~exist(tdir, 'dir')
    return;
end
hit = 0;
for kk = 1:numel(requiredFiles)
    if exist(fullfile(tdir, requiredFiles{kk}), 'file') == 2
        hit = hit + 1;
    end
end
tf = hit >= 1;
end

function figs = targetFigures()
figs = findall(0, 'Type', 'figure');
if isempty(figs), return; end
keep = false(size(figs));
for ii = 1:numel(figs)
    keep(ii) = isgraphics(figs(ii), 'figure') && ~isGuiFigure(figs(ii));
end
figs = figs(keep);
end

function tf = isGuiFigure(f)
tf = false;
try
    tf = strcmpi(safeGetTag(f), 'FBV2_MainFig');
catch
    tf = false;
end
end

function axs = targetAxes(f, includeInset)
%TARGETAXES 返回一个 Fig 中全部普通绘图坐标轴。
% 关键点：subplot/tiledlayout 中的所有子图都要返回，不能只返回 CurrentAxes。
if nargin < 2, includeInset = false; end
axs = gobjects(0);
if isempty(f) || ~isgraphics(f, 'figure')
    return;
end

try
    axs = findall(f, '-isa', 'matlab.graphics.axis.Axes');
catch
    try
        axs = findall(f, 'Type', 'axes');
    catch
        axs = gobjects(0);
    end
end
if isempty(axs), return; end

keep = false(size(axs));
for ii = 1:numel(axs)
    keep(ii) = isgraphics(axs(ii), 'axes') && ~isSpecialAxes(axs(ii), includeInset);
end
axs = axs(keep);
try
    axs = flipud(axs(:));  % 尽量恢复 subplot/tiledlayout 的视觉顺序
catch
    axs = axs(:);
end
end

function ax = mainAxes(f)
ax = [];
axs = targetAxes(f, false);
if isempty(axs), return; end
areas = zeros(size(axs));
for ii = 1:numel(axs)
    try
        oldUnits = get(axs(ii), 'Units');
        set(axs(ii), 'Units', 'normalized');
        pos = get(axs(ii), 'Position');
        set(axs(ii), 'Units', oldUnits);
        areas(ii) = pos(3) * pos(4);
    catch
        areas(ii) = 0;
    end
end
[~, idx] = max(areas);
ax = axs(idx);
end

function tf = isSpecialAxes(ax, includeInset)
if nargin < 2, includeInset = false; end
if isempty(ax) || ~isgraphics(ax, 'axes')
    tf = true;
    return;
end

tag = lower(safeGetTag(ax));
cls = lower(class(ax));

isLegendColorbar = ~isempty(strfind(tag, 'legend')) || ...
                  ~isempty(strfind(tag, 'colorbar')) || ...
                  ~isempty(strfind(cls, 'legend')) || ...
                  ~isempty(strfind(cls, 'colorbar'));
isInset = strcmpi(tag, 'FBV2_InsetAxes');
isPreview = strcmpi(tag, 'FBV2_ColorPreviewAxes');

tf = isLegendColorbar || isPreview || (~includeInset && isInset);
end

function tag = safeGetTag(h)
tag = '';
try
    tag = get(h, 'Tag');
    if isstring(tag), tag = char(tag); end
catch
    tag = '';
end
end

function styleAxes(ax, varargin)
if isempty(ax) || ~isgraphics(ax, 'axes'), return; end
p = inputParser;
p.addParameter('LineWidth', 1.0);
p.addParameter('Box', 'on');
p.addParameter('TickDir', 'in');
p.addParameter('FontName', 'Helvetica');
p.addParameter('FontSize', 10);
p.addParameter('Grid', 'on');
p.addParameter('Hold', 'on');
p.parse(varargin{:});
s = p.Results;

try set(ax, 'LineWidth', s.LineWidth, 'Box', s.Box, 'TickDir', s.TickDir, ...
        'FontName', s.FontName, 'FontSize', s.FontSize); catch, end
try grid(ax, s.Grid); catch, end
try
    if strcmpi(s.Hold, 'on') || isequal(s.Hold, true)
        hold(ax, 'on');
    end
catch
end
end

function setMinorGrid(ax, state)
if isempty(ax) || ~isgraphics(ax, 'axes'), return; end
if islogical(state)
    if state, state = 'on'; else, state = 'off'; end
end
if isstring(state), state = char(state); end
try set(ax, 'XMinorGrid', state); catch, end
try set(ax, 'YMinorGrid', state); catch, end
try set(ax, 'ZMinorGrid', state); catch, end
if strcmpi(state, 'on')
    try set(ax, 'MinorGridLineStyle', ':'); catch, end
    try set(ax, 'MinorGridAlpha', 0.30); catch, end
end
end
