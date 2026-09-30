import Foundation

// ============================================================
// iPad 宾客大屏（GET / 的响应体）
//  - 全部内嵌为 Swift 字符串常量，零静态资源文件
//  - vanilla JS，无框架；MJPEG 用 <img src="/live">（Safari 原生支持）
//  - iPad 是唯一朝向宾客的屏：armed/gestureWait/countdown/capturing
//    全屏取景（镜像翻转）+ 姿势引导卡；idle 吸引页背景历史成片轮播
//  - 视觉风格与 BoothUI 一致：奶油底 #FFF7F0 / 蜜桃粉 #FF8FAB /
//    大圆角 / 大字号，全中文可爱风
//  - WS 协议（与 BoothWebService 对应）：
//     收 {"type":"state","state":"...","secondsLeft":n,"shot":n,"of":n,
//          "photoId":"uuid","copies":n,"message":"...",
//          "showPrint":bool,"filters":[{"id":"vivid","name":"鲜艳"}]}
//     发 {"type":"print","copies":n} / {"type":"retake"} /
//         {"type":"mode","kind":"single"|"collage","shots":n,"layout":"strip"} /
//         {"type":"filter","filter":"vivid"}
//  - /gallery /slideshow：独立相册页 / 放映页（不连 WS，纯拉 /api/photos）
// ============================================================

enum WebAssets {

    /// iPad 主页面（HTML + CSS + JS 一体）
    static let indexHTML: String = #"""
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover, user-scalable=no">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <title>LUMIX 拍照屋</title>
        <style>
          :root { --peach:#FF8FAB; --cream:#FFF7F0; --ink:#5B4A4F; }
          * { margin:0; padding:0; box-sizing:border-box; -webkit-user-select:none; user-select:none;
              -webkit-tap-highlight-color:transparent; }
          html, body { height:100%; }
          body {
            background:var(--cream); color:var(--ink);
            font-family:-apple-system,"PingFang SC","Hiragino Sans GB",sans-serif;
            display:flex; flex-direction:column; overflow:hidden;
          }
          header { padding:20px 24px 4px; text-align:center; font-size:22px; font-weight:700; letter-spacing:3px; }
          main { flex:1; display:flex; align-items:center; justify-content:center; padding:24px; }
          .card { text-align:center; max-width:92%; }
          /* 内容层浮于取景/轮播层之上 */
          header, main { position:relative; z-index:2; }

          /* 连接指示点 */
          .dot { position:fixed; top:18px; left:18px; width:16px; height:16px; border-radius:50%;
                 background:#D8CCC6; z-index:9; transition:background .3s; }
          .dot.on { background:#7BC47F; box-shadow:0 0 14px #7BC47F; }

          /* 实时取景：<img> 单实例在 livebox(待机小窗，供操作员检查构图) 与
             livefull(全屏取景) 之间搬移，同一 MJPEG 连接不重建 */
          #livebox { position:fixed; top:14px; right:14px; width:184px; border-radius:18px; overflow:hidden;
                     border:5px solid #fff; box-shadow:0 10px 26px rgba(91,74,79,.22); z-index:8;
                     background:#fff; display:none; }
          #livebox img { display:block; width:100%; min-height:70px; }
          body.idle #livebox { display:block; }
          #livebox.hidden { display:none !important; }

          /* 全屏取景层（armed/gestureWait/countdown/capturing）：镜像翻转像照镜子 */
          #livefull { position:fixed; inset:0; display:none; background:#2B2225; z-index:0; }
          #livefull img { width:100%; height:100%; object-fit:contain; transform:scaleX(-1); }
          body.framed #livefull { display:block; }

          /* 待机背景历史成片轮播（同 Mac 吸引页：12% 透明度不干扰前景） */
          #idlebg { position:fixed; inset:0; display:none; background-size:cover; background-position:center;
                    opacity:0; transition:opacity 1s; z-index:0; filter:blur(1px); }
          body.idle #idlebg { display:block; }

          /* 全屏取景态：提示卡沉底，隐藏页眉/链接保持画面纯粹；倒计时数字仍居中 */
          body.framed header, body.framed .links { display:none; }
          body.framed main { align-items:flex-end; padding-bottom:9vh; }
          body.framed.countdown main { align-items:center; padding-bottom:24px; }

          /* 姿势引导卡（贴在全屏取景下方，同 Mac GuestGuidanceView） */
          .guide-card { background:rgba(255,255,255,.93); border-radius:28px; padding:22px 40px;
                        box-shadow:0 14px 34px rgba(91,74,79,.32); text-align:center; }
          .guide-emoji { font-size:64px; line-height:1.2; }
          .guide-emoji .eic { width:84px; height:84px; }
          .guide-text { font-size:27px; font-weight:700; margin-top:8px; }

          .big-emoji { font-size:118px; line-height:1.25; }
          .big-emoji img { width:190px; height:190px; object-fit:contain; }
          .tic { height:1em; vertical-align:-0.12em; }
          .eic { width:110px; height:110px; object-fit:contain; }
          .big-text  { font-size:34px; font-weight:700; margin-top:16px; }
          .sub       { font-size:22px; margin-top:10px; opacity:.7; }

          /* 倒计时：全屏大数字 + 弹跳动画 */
          .countdown { font-size:46vw; font-weight:800; color:var(--peach); line-height:1;
                       text-shadow:0 10px 40px rgba(255,143,171,.4);
                       animation:pop .9s ease-out infinite; }
          @keyframes pop { 0%{transform:scale(1.4);opacity:.35} 35%{transform:scale(1);opacity:1} 100%{transform:scale(1)} }

          /* 成片与操作区 */
          .photo { max-width:88vw; max-height:58vh; border-radius:28px; border:10px solid #fff;
                   box-shadow:0 18px 50px rgba(91,74,79,.28); }
          .controls { display:flex; gap:18px; margin-top:26px; align-items:center;
                      justify-content:center; flex-wrap:wrap; }
          .btn { border:none; border-radius:999px; padding:20px 44px; font-size:26px; font-weight:700;
                 cursor:pointer; }
          .btn-peach { background:var(--peach); color:#fff; box-shadow:0 12px 28px rgba(255,143,171,.5); }
          .btn-ghost { background:#fff; color:var(--peach); border:3px solid var(--peach); }
          .stepper { display:flex; align-items:center; gap:14px; background:#fff; border-radius:999px;
                     padding:10px 20px; box-shadow:0 8px 20px rgba(91,74,79,.15); }
          .stepper button { width:52px; height:52px; border-radius:50%; border:none; background:var(--cream);
                            font-size:30px; font-weight:800; color:var(--peach); cursor:pointer; }
          .stepper .num { font-size:34px; font-weight:800; min-width:52px; text-align:center; }
          .stepper .unit { font-size:18px; opacity:.55; }

          /* 待机页模式选择 */
          .mode-row { display:flex; gap:16px; margin-top:32px; justify-content:center; }
          .mode-btn { background:#fff; border:3px solid var(--peach); color:var(--ink); border-radius:24px;
                      padding:16px 26px; font-size:20px; font-weight:600; cursor:pointer; }
          .mode-btn.on { background:var(--peach); color:#fff; box-shadow:0 10px 24px rgba(255,143,171,.45); }

          /* REVIEW 滤镜选择条（拍后自选） */
          .filter-row { display:flex; gap:12px; margin-top:22px; justify-content:center; flex-wrap:wrap; }
          .filter-btn { background:#fff; border:3px solid #F3D9D2; color:var(--ink); border-radius:999px;
                        padding:12px 24px; font-size:19px; font-weight:600; cursor:pointer; }

          /* SELECT 选片页：实时预览大图 + 缩略图 + 拼图样式 + 修图风格 */
          .sel-wrap { display:flex; gap:16px; margin-top:18px; align-items:stretch; justify-content:center; flex:1; min-height:0; }
          .sel-preview { flex:1 1 auto; max-width:52%; height:auto; max-height:100%; object-fit:contain;
                         background:#fff; border-radius:16px; border:4px solid #fff; box-shadow:0 8px 22px rgba(91,74,79,.22); }
          .sel-side { flex:0 0 40%; display:flex; flex-direction:column; gap:10px; min-height:0; justify-content:center; }
          .sel-row { display:flex; gap:8px; justify-content:center; flex-wrap:wrap; }
          .sel-thumb { width:76px; height:100px; object-fit:cover; border-radius:10px; border:3px solid #fff;
                       box-shadow:0 4px 12px rgba(91,74,79,.16); cursor:pointer; transition:transform .15s, border-color .15s; }
          .sel-thumb.on { border-color:var(--peach); transform:scale(1.07); box-shadow:0 6px 16px rgba(255,143,171,.5); }
          .layout-row { display:flex; gap:8px; justify-content:center; flex-wrap:wrap; }
          .layout-btn { background:#fff; border:3px solid #F3D9D2; color:var(--ink); border-radius:999px;
                        padding:9px 15px; font-size:15px; font-weight:600; cursor:pointer; }
          .layout-btn.on { background:var(--peach); color:#fff; border-color:var(--peach); }
          .filter-btn.small { padding:8px 14px; font-size:14px; }
          .filter-btn.small.on { border-color:var(--peach); color:var(--peach); box-shadow:0 6px 14px rgba(255,143,171,.35); }
          .sel-hint { text-align:center; font-size:14px; opacity:.65; margin-top:2px; }
          .filter-btn.on { border-color:var(--peach); color:var(--peach);
                           box-shadow:0 8px 18px rgba(255,143,171,.35); }

          /* 待机页底部入口（相册 / 放映） */
          .links { position:fixed; bottom:16px; left:0; right:0; text-align:center; font-size:17px; }
          .links a { color:var(--peach); text-decoration:none; font-weight:700; margin:0 12px;
                     -webkit-touch-callout:none; }

          .fail { background:#FFE3E3; color:#C0392B; border-radius:24px; padding:26px 38px; font-size:24px; }

          .email-row { display:flex; gap:10px; align-items:center; margin:14px 0 0; }
          .email-row input { flex:1; font-size:17px; padding:12px 16px; border-radius:14px;
                             border:2px solid #FFD5DE; background:#fff; color:var(--ink);
                             -webkit-user-select:text; user-select:text; }
          .email-row input:focus { outline:none; border-color:var(--peach); }
          .email-ok { justify-content:center; font-size:17px; color:#4CAF50; background:#EAF7EA;
                      border-radius:14px; padding:10px; }
        </style>
        </head>
        <body>
          <div id="dot" class="dot"></div>
          <div id="idlebg"></div>
          <div id="livefull"></div>
          <header>LUMIX 拍照屋</header>
          <div id="livebox"><img id="liveimg" alt="实时取景" src="/live"></div>
          <main><div class="card" id="stage"></div></main>
          <div class="links"><a href="/gallery"><img class="tic" src="/theme/icon/album.png" onerror="this.outerHTML='📖'"> 相册</a><a href="/slideshow"><img class="tic" src="/theme/icon/film.png" onerror="this.outerHTML='🎞️'"> 放映</a><a href="/guestbook">💌 留言簿</a></div>

        <script>
        var ws = null, cur = null, copies = 2, modeKind = 'collage', takeTimer = null;
        var filters = null, curFilter = 'none', showPrint = true, showEmail = false, curPhotoId = null, emailDone = false;
        var selLayouts = [], selShots = [], curLayout = 'strip', selDefault = 'strip', selPick = -1;
        var selFilters = [], selFilter = 'none';

        var dot     = document.getElementById('dot');
        var stage   = document.getElementById('stage');
        var livebox = document.getElementById('livebox');
        var liveimg = document.getElementById('liveimg');
        var livefull = document.getElementById('livefull');

        // 取景 <img> 在小窗与全屏层之间搬移（同元素 → 同一 MJPEG 连接不重建）
        function placeLive(framed) {
          var box = framed ? livefull : livebox;
          if (liveimg.parentNode !== box) box.appendChild(liveimg);
        }

        // 主题图标：优先显示主题包插画（/theme/icon/<key>.png），加载失败回退 emoji 文本
        function ic(key, emoji, cls) {
          return '<img class="' + (cls || 'tic') + '" src="/theme/icon/' + key + '.png" alt="' + emoji +
                 '" onerror="this.outerHTML=\'' + emoji + '\'">';
        }

        // LiveView 小窗点击收起/展开
        livebox.addEventListener('click', function () { livebox.classList.toggle('hidden'); });
        // MJPEG 流断了（服务重启）2s 后自动重连
        liveimg.onerror = function () {
          setTimeout(function () { liveimg.src = '/live?t=' + Date.now(); }, 2000);
        };

        function setConnected(v) { dot.classList.toggle('on', v); }

        // ---------- WebSocket：断线 2s 自动重连 ----------
        function connect() {
          try { ws = new WebSocket('ws://' + location.host + '/ws'); }
          catch (e) { setConnected(false); setTimeout(connect, 2000); return; }
          ws.onopen = function () { setConnected(true); };
          ws.onclose = function () { setConnected(false); setTimeout(connect, 2000); };
          ws.onerror = function () { try { ws.close(); } catch (e) {} };
          ws.onmessage = function (ev) {
            var m = null;
            try { m = JSON.parse(ev.data); } catch (e) { return; }
            if (m && m.type === 'state') render(m);
          };
        }

        function send(o) { if (ws && ws.readyState === 1) ws.send(JSON.stringify(o)); }

        // ---------- 状态机镜像渲染 ----------
        function render(m) {
          var s = m.state;
          // 打印完成（printing → idle）：先显示"请取照片"再回待机
          if (cur === 'printing' && s === 'idle') { renderTakePhoto(); return; }
          cur = s;
          var framed = (s === 'armed' || s === 'gestureWait' || s === 'countdown' || s === 'capturing');
          document.body.className = s + (framed ? ' framed' : '');
          if (takeTimer) { clearTimeout(takeTimer); takeTimer = null; }
          placeLive(framed);
          if (s === 'idle') startSlides(); else stopSlides();

          if (s === 'countdown') {
            stage.innerHTML = '<div class="countdown">' + (m.secondsLeft || 0) + '</div>';
            return;
          }
          if (s === 'armed' || s === 'gestureWait') { renderGuide(s); return; }
          if (s === 'capturing') { renderCapturing(m); return; }
          if (s === 'select' && m.shots) {
            selLayouts = m.layouts || [];
            selDefault = m.defaultLayout || 'strip';
            selShots = m.shots;
            selFilters = m.filters || [];
            curLayout = selDefault; selPick = -1; selFilter = 'none';
            renderSelect();
            return;
          }
          if (s === 'review' && m.photoId) {
            copies = m.copies || 2;
            if (m.filters) { filters = m.filters; }
            if (typeof m.showPrint === 'boolean') { showPrint = m.showPrint; }
            if (typeof m.showEmail === 'boolean') { showEmail = m.showEmail; }
            if (cur !== 'review') { curFilter = 'none'; emailDone = false; }   // 新一轮流程回到原片
            curPhotoId = m.photoId;
            renderReview(m.photoId);
            return;
          }
          var map = {
            idle:       ['camera', '📸', '看镜头准备拍照'],
            processing: ['sparkle', '✨', '正在修图'],
            printing:   ['printer', '🖨️', '已加入打印队列']
          };
          if (map[s]) {
            var sub = '';
            if (s === 'capturing' && m.shot && m.of) sub = '第 ' + m.shot + ' / ' + m.of + ' 张';
            if (s === 'printing' && m.copies)       sub = '正在为你打印 ' + m.copies + ' 张，可先让下一位开始拍照';
            stage.innerHTML =
              '<div class="big-emoji">' + ic(map[s][0], map[s][1]) + '</div>' +
              '<div class="big-text">' + map[s][2] + '</div>' +
              (sub ? '<div class="sub">' + sub + '</div>' : '') +
              (s === 'idle' ? modeRow() : '');
            syncModeButtons();
            return;
          }
          if (s === 'failure') {
            stage.innerHTML = '<div class="fail">' + (m.message || '出错了，请稍候') + '</div>';
            return;
          }
          stage.innerHTML = '<div class="big-emoji">' + ic('camera', '📷') + '</div><div class="big-text">LUMIX 拍照屋</div>';
        }

        // 全屏取景期（armed/gestureWait）：取景铺满 + 底部姿势引导卡（同 Mac GuestGuidanceView）
        function renderGuide(s) {
          var pose = s === 'armed'
            ? { icons: ['stand', '👀'],  emojis: ['🧍‍♀️', '👀'], text: '站好啦，看着你啦' }
            : { icons: ['peace', 'wave'], emojis: ['✌️', '👋'], text: '比个耶或挥手，开始拍照' };
          stage.innerHTML =
            '<div class="guide-card">' +
              '<div class="guide-emoji">' + pose.icons.map(function (k, i) {
                return ic(k, pose.emojis[i], 'eic');
              }).join('') + '</div>' +
              '<div class="guide-text">' + pose.text + '</div>' +
            '</div>';
        }

        // 全屏取景期（capturing）：取景铺满 + 大字拍摄提示（同 Mac GuestCapturingView）
        function renderCapturing(m) {
          var sub = (m.shot && m.of) ? '第 ' + m.shot + ' / ' + m.of + ' 张' : '';
          stage.innerHTML =
            '<div class="guide-card">' +
              '<div class="guide-emoji">' + ic('camera', '📷', 'eic') + '</div>' +
              '<div class="guide-text">拍摄中 ' + (sub ? '· ' + sub : '') + '</div>' +
            '</div>';
        }

        // 待机页拍摄模式选择（单张 / 四连拍拼图）
        function modeRow() {
          return '<div class="mode-row">' +
            '<button class="mode-btn" data-kind="single">单张照片</button>' +
            '<button class="mode-btn" data-kind="collage">四连拍拼图</button>' +
            '</div>';
        }
        function syncModeButtons() {
          var btns = stage.querySelectorAll('.mode-btn');
          for (var i = 0; i < btns.length; i++) {
            btns[i].classList.toggle('on', btns[i].dataset.kind === modeKind);
          }
        }
        function pickMode(kind) {
          modeKind = kind;
          send({ type: 'mode', kind: kind, shots: 4 });
          syncModeButtons();
        }

        // REVIEW：全屏成片 + 滤镜选择条（可选）+ 张数步进器（1-4）+ 打印 / 重拍
        // 换滤镜后服务端会推新 review 状态（新 photoId），img 自然换图不落浏览器缓存
        function renderReview(photoId) {
          var filterRow = '';
          if (filters && filters.length) {
            filterRow = '<div class="filter-row">' + filters.map(function (f) {
              return '<button class="filter-btn' + (f.id === curFilter ? ' on' : '') +
                     '" data-filter="' + f.id + '">' + f.name + '</button>';
            }).join('') + '</div>';
          }
          var printControls = showPrint
            ? '<div class="stepper">' +
                '<button id="cop-minus">−</button>' +
                '<span class="num" id="cop-num">' + copies + '</span><span class="unit">张</span>' +
                '<button id="cop-plus">＋</button>' +
              '</div>' +
              '<button class="btn btn-peach" id="btn-print">打印 ' + ic('printer', '🖨️') + '</button>'
            : '';
          // 邮箱采集条：输邮箱领电子版（活动营销；仅落盘不发送）
          var emailRow = (showEmail && !emailDone)
            ? '<div class="email-row">' +
                '<input type="email" id="email-input" placeholder="输入邮箱领电子版" ' +
                'autocomplete="off" autocapitalize="off" spellcheck="false">' +
                '<button class="btn btn-ghost" id="btn-email">发送 ' + ic('mail', '✉️') + '</button>' +
              '</div>'
            : (emailDone
                ? '<div class="email-row email-ok">✅ 已收到，稍后会发到你邮箱</div>'
                : '');
          stage.innerHTML =
            '<img class="photo" src="/photo/' + photoId + '?t=' + Date.now() + '">' +
            filterRow +
            emailRow +
            '<div class="controls">' +
              printControls +
              '<button class="btn btn-ghost" id="btn-retake">重拍 ' + ic('retake', '🔄') + '</button>' +
            '</div>';
        }

        function pickFilter(id) {
          if (id === curFilter) return;
          curFilter = id;
          send({ type: 'filter', filter: id });
          syncFilterButtons();
        }
        function syncFilterButtons() {
          var btns = stage.querySelectorAll('.filter-btn');
          for (var i = 0; i < btns.length; i++) {
            btns[i].classList.toggle('on', btns.dataset.filter === curFilter);
          }
        }

        // SELECT 选片页：左实时预览大图 + 右（缩略图/拼图样式/修图风格/确认）
        function renderSelect() {
          var thumbs = selShots.map(function (sh) {
            return '<img class="sel-thumb' + (sh.i === selPick ? ' on' : '') +
              '" data-shot="' + sh.i + '" src="/photo/' + sh.id + '?t=' + Date.now() + '" alt="第' + (sh.i + 1) + '张">';
          }).join('');
          var layoutRow = selLayouts.length
            ? '<div class="layout-row">' + selLayouts.map(function (l) {
                return '<button class="layout-btn' + (l.id === curLayout && selPick < 0 ? ' on' : '') +
                  '" data-layout="' + l.id + '">' + l.name + '</button>';
              }).join('') + '</div>'
            : '';
          var filterRow = selFilters.length
            ? '<div class="filter-row">' + selFilters.map(function (f) {
                return '<button class="filter-btn small' + (f.id === selFilter ? ' on' : '') +
                  '" data-selfilter="' + f.id + '">' + f.name + '</button>';
              }).join('') + '</div>'
            : '';
          var goText = selPick >= 0 ? '就选这张 💖' : '就选这些 💖';
          stage.innerHTML =
            '<div class="sel-wrap">' +
            '<img class="sel-preview" id="sel-preview" alt="实时预览">' +
            '<div class="sel-side">' +
            '<div class="sel-row">' + thumbs + '</div>' +
            '<div class="sel-hint">点缩略图只出那一张，再点取消</div>' +
            layoutRow +
            filterRow +
            '<div class="controls">' +
            '<button class="btn btn-ghost" id="btn-sel-retake">重拍 🔄</button>' +
            '<button class="btn btn-peach" id="btn-sel-go">' + goText + '</button>' +
            '</div>' +
            '</div>' +
            '</div>';
          refreshSelPreview();
        }
        
        // 实时预览：服务端 /selectpreview 合成（布局/单张/滤镜任一变化刷新）
        var selPreviewSeq = 0;
        function refreshSelPreview() {
          var img = document.getElementById('sel-preview');
          if (!img) return;
          var ids = selShots.map(function (sh) { return sh.id; }).join(',');
          var q = 'ids=' + ids + '&layout=' + curLayout +
            (selPick >= 0 ? '&single=' + selPick : '') + '&filter=' + selFilter;
          var seq = ++selPreviewSeq;
          var probe = new Image();
          probe.onload = function () {
            if (seq !== selPreviewSeq) return;   // 过期结果丢弃
            img.src = probe.src;
          };
          probe.src = '/selectpreview?' + q + '&t=' + Date.now();
        }
        function pickShot(i) {
          selPick = (selPick === i) ? -1 : i;   // 再点一次取消
          syncSelectUI();
          refreshSelPreview();
        }
        function pickLayout(id) {
          curLayout = id;
          selPick = -1;   // 换样式则回到整版模式
          syncSelectUI();
          refreshSelPreview();
        }
        function pickSelFilter(id) {
          selFilter = id;
          syncSelectUI();
          refreshSelPreview();
        }
        function syncSelectUI() {
          var thumbs = stage.querySelectorAll('.sel-thumb');
          for (var k = 0; k < thumbs.length; k++) {
            thumbs[k].classList.toggle('on', parseInt(thumbs[k].dataset.shot, 10) === selPick);
          }
          var btns = stage.querySelectorAll('.layout-btn');
          for (var k2 = 0; k2 < btns.length; k2++) {
            btns[k2].classList.toggle('on', btns[k2].dataset.layout === curLayout && selPick < 0);
          }
          var fbtns = stage.querySelectorAll('.filter-btn.small');
          for (var k3 = 0; k3 < fbtns.length; k3++) {
            fbtns[k3].classList.toggle('on', fbtns[k3].dataset.selfilter === selFilter);
          }
          var go = document.getElementById('btn-sel-go');
          if (go) go.textContent = selPick >= 0 ? '就选这张 💖' : '就选这些 💖';
        }
        function confirmSelection() {
          var payload = {
            type: 'selectOutput',
            kind: selPick >= 0 ? 'single' : 'collage',
            layout: curLayout,
            indexes: selPick >= 0 ? [selPick] : [],
            filter: selFilter
          };
          send(payload);
        }

        // 打印完成后：请取照片（8s 后自动回待机）
        function renderTakePhoto() {
          cur = 'takephoto';
          document.body.classList.remove('printing');
          stage.innerHTML =
            '<div class="big-emoji">' + ic('confetti', '🎉') + '</div>' +
            '<div class="big-text">请取照片</div>' +
            '<div class="sub">手机扫码可保存电子版</div>';
          takeTimer = setTimeout(function () {
            if (cur === 'takephoto') render({ state: 'idle' });
          }, 8000);
        }

        // ---------- 事件委托（stage 内容每次重建，统一在这里接点击） ----------
        stage.addEventListener('click', function (ev) {
          var b = ev.target.closest('button');
          var th = ev.target.closest('.sel-thumb');
          if (th) { pickShot(parseInt(th.dataset.shot, 10)); return; }
          if (b && b.dataset.layout) { pickLayout(b.dataset.layout); return; }
          if (b && b.dataset.selfilter) { pickSelFilter(b.dataset.selfilter); return; }
          if (!b) return;
          if (b.dataset.kind) { pickMode(b.dataset.kind); return; }
          if (b.dataset.filter) { pickFilter(b.dataset.filter); return; }
          if (b.id === 'btn-sel-go') { confirmSelection(); return; }
          if (b.id === 'btn-sel-retake') { send({ type: 'retake' }); }
          if (b.id === 'cop-minus') { copies = Math.max(1, copies - 1); }
          if (b.id === 'cop-plus')  { copies = Math.min(4, copies + 1); }
          if (b.id === 'cop-minus' || b.id === 'cop-plus') {
            var n = document.getElementById('cop-num');
            if (n) n.textContent = copies;
            return;
          }
          if (b.id === 'btn-print')  { send({ type: 'print', copies: copies }); }
          if (b.id === 'btn-retake') { send({ type: 'retake' }); }
          if (b.id === 'btn-email') {
            var inp = document.getElementById('email-input');
            var v = inp ? inp.value.trim() : '';
            if (!v) { if (inp) inp.focus(); return; }
            send({ type: 'email', email: v, photoId: curPhotoId });
            emailDone = true;
            var row = b.closest('.email-row');
            if (row) { row.outerHTML = '<div class="email-row email-ok">✅ 已收到，稍后会发到你邮箱</div>'; }
          }
        });

        // 邮箱输入回车提交
        stage.addEventListener('keydown', function (ev) {
          if (ev.key !== 'Enter') return;
          if (ev.target && ev.target.id === 'email-input') {
            var btn = document.getElementById('btn-email');
            if (btn) btn.click();
          }
        });

        // ---------- 待机背景历史成片轮播（同 Mac 吸引页：12% 透明度） ----------
        var slideTimer = null, slidePhotos = [], slideIndex = 0, slideOn = false;
        function startSlides() {
          if (slideOn) return;
          slideOn = true;
          fetch('/api/photos').then(function (r) { return r.json(); })
            .then(function (d) {
              slidePhotos = (d.photos || []).map(function (p) { return p.url; });
              if (slidePhotos.length > 1) { slidePhotos.sort(function () { return Math.random() - 0.5; }); }
              showSlide();
              if (!slideTimer && slidePhotos.length > 1) {
                slideTimer = setInterval(function () {
                  slideIndex = (slideIndex + 1) % slidePhotos.length;
                  showSlide();
                }, 5000);
              }
            })
            .catch(function () {});
        }
        function showSlide() {
          var bg = document.getElementById('idlebg');
          if (!bg || !slidePhotos.length) return;
          if (!slidePhotos[slideIndex]) { bg.style.opacity = '0'; return; }
          // 预加载新图，加载完成再淡入，避免闪空
          var probe = new Image();
          probe.onload = function () { bg.style.backgroundImage = 'url("' + probe.src + '")'; bg.style.opacity = '0.12'; };
          probe.src = slidePhotos[slideIndex];
        }
        function stopSlides() {
          slideOn = false;
          if (slideTimer) { clearInterval(slideTimer); slideTimer = null; }
          var bg = document.getElementById('idlebg');
          if (bg) { bg.style.opacity = '0'; }
        }

        // ---------- 屏幕常亮（iPad Safari；不支持时静默降级，需配合引导式访问） ----------
        var wakeLock = null;
        function keepAwake() {
          if (!navigator.wakeLock) return;
          navigator.wakeLock.request('screen').then(function (l) {
            wakeLock = l;
            l.addEventListener('release', function () { wakeLock = null; });
          }).catch(function () {});
          // 页面重新可见时补请求（iOS 切后台会释放 Wake Lock）
          document.addEventListener('visibilitychange', function () {
            if (document.visibilityState === 'visible' && !wakeLock) keepAwake();
          });
        }
        keepAwake();

        render({ state: 'idle' });
        connect();
        </script>
        </body>
        </html>
        """#

    /// 相册页通用骨架（gallery / slideshow 共用样式，gallery 用瀑布流网格）
    private static func pageShell(title: String, bodyHTML: String, script: String) -> String {
        #"""
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover, user-scalable=no">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <title>\#(title)</title>
        <style>
          :root { --peach:#FF8FAB; --cream:#FFF7F0; --ink:#5B4A4F; }
          * { margin:0; padding:0; box-sizing:border-box; -webkit-user-select:none; user-select:none;
              -webkit-tap-highlight-color:transparent; }
          html, body { height:100%; }
          body {
            background:var(--cream); color:var(--ink);
            font-family:-apple-system,"PingFang SC","Hiragino Sans GB",sans-serif;
            display:flex; flex-direction:column;
          }
          header { padding:18px 24px 10px; text-align:center; font-size:22px; font-weight:700;
                   letter-spacing:3px; }
          header a { color:var(--peach); text-decoration:none; font-size:17px; font-weight:700;
                     display:inline-block; margin-top:6px; }
          main { flex:1; overflow-y:auto; -webkit-overflow-scrolling:touch; }
          .empty { text-align:center; padding:80px 20px; font-size:22px; opacity:.6; }
          .empty .emoji { font-size:80px; display:block; margin-bottom:14px; }
        </style>
        </head>
        <body>
          <header>\#(title)<br><a href="/">← 回宾客屏</a></header>
          <main>\#(bodyHTML)</main>
        <script>
        \#(script)
        </script>
        </body>
        </html>
        """#
    }

    /// 拉取 /api/photos 历史成片列表（失败返回空数组，页面显示空态）
    private static let fetchScript = #"""
        function fetchPhotos() {
          return fetch('/api/photos').then(function (r) { return r.json(); })
            .then(function (d) { return d.photos || []; })
            .catch(function () { return []; });
        }
        """#

    /// iPad 独立相册页：两列瀑布流，点图全屏查看（长按可保存）
    static let galleryHTML: String = pageShell(
        title: "<img class=\"tic\" src=\"/theme/icon/camera.png\" onerror=\"this.outerHTML='📷'\"> LUMIX 相册",
        bodyHTML: #"""
        <div id="grid"></div>
        <div class="empty" id="empty" style="display:none">
          <span class="emoji"><img class="eic" src="/theme/icon/mailbox.png" onerror="this.outerHTML='📭'"></span>还没有成片，拍一张就有了
        </div>
        <div class="op-hint">长按任意成片可操作员补打（需口令）</div>
        <style>
          #grid { display:grid; grid-template-columns:repeat(2,1fr); gap:14px; padding:14px; }
          #grid img { width:100%; display:block; border-radius:18px; border:6px solid #fff;
                      box-shadow:0 8px 22px rgba(91,74,79,.18); }
          #lightbox { position:fixed; inset:0; background:rgba(91,74,79,.92); display:none;
                      align-items:center; justify-content:center; z-index:9; }
          #lightbox img { max-width:94vw; max-height:92vh; border-radius:24px;
                          border:8px solid #fff; }
          .op-hint { text-align:center; font-size:13px; opacity:.45; padding:8px 0 16px; }
          #reprint-dialog { position:fixed; inset:0; background:rgba(91,74,79,.55); display:none;
                            align-items:center; justify-content:center; z-index:99; }
          #reprint-dialog .box { background:#fff; border-radius:22px; padding:26px 30px; text-align:center;
                                 box-shadow:0 16px 50px rgba(0,0,0,.25); }
          #reprint-dialog img { width:120px; border-radius:12px; border:4px solid #fff;
                                margin-bottom:14px; }
          #reprint-dialog .tip { font-size:15px; color:#5B4A4F; margin-bottom:12px; }
          #reprint-dialog input { font-size:20px; text-align:center; letter-spacing:6px; width:170px;
                                  padding:10px 14px; border-radius:12px; border:2px solid #FFD5DE;
                                  -webkit-user-select:text; user-select:text; margin-bottom:14px; }
          #reprint-dialog input:focus { outline:none; border-color:#FF8FAB; }
          #reprint-dialog button { font-size:17px; font-weight:700; padding:12px 30px; border-radius:14px;
                                   border:none; margin:0 8px; cursor:pointer; }
          #reprint-dialog .ok { background:#FF8FAB; color:#fff; }
          #reprint-dialog .cancel { background:#F1EAE6; color:#5B4A4F; }
        </style>
        <div id="lightbox"><img id="lightbox-img" alt="成片大图"></div>
        <div id="reprint-dialog">
          <div class="box">
            <img id="reprint-thumb" alt="待补打成片">
            <div class="tip">操作员补打：验证口令后重新打印</div>
            <input type="password" id="reprint-code" placeholder="口令" inputmode="numeric">
            <div>
              <button class="cancel" id="reprint-cancel">取消</button>
              <button class="ok" id="reprint-go">补打 🖨️</button>
            </div>
          </div>
        </div>
        """#,
        script: #"""
        var grid = document.getElementById('grid');
        var lightbox = document.getElementById('lightbox');
        var lightboxImg = document.getElementById('lightbox-img');

        function render(photos) {
          if (!photos.length) {
            document.getElementById('empty').style.display = 'block';
            return;
          }
          grid.innerHTML = photos.map(function (p) {
            return '<img src="' + p.url + '" loading="lazy" data-full="' + p.url +
                   '" data-date="' + p.date + '" data-session="' + p.session + '" alt="成片">';
          }).join('');
        }

        grid.addEventListener('click', function (ev) {
          if (ev.target.tagName !== 'IMG') return;
          lightboxImg.src = ev.target.dataset.full;
          lightbox.style.display = 'flex';
        });
        lightbox.addEventListener('click', function () { lightbox.style.display = 'none'; });

        // ---------- 操作员重打（长按 800ms 弹口令窗） ----------
        var dlg = document.getElementById('reprint-dialog');
        var dlgThumb = document.getElementById('reprint-thumb');
        var dlgCode = document.getElementById('reprint-code');
        var reprintTarget = null, pressTimer = null;

        function openReprint(img) {
          reprintTarget = { date: img.dataset.date, session: img.dataset.session };
          dlgThumb.src = img.dataset.full;
          dlgCode.value = '';
          dlg.style.display = 'flex';
          setTimeout(function () { dlgCode.focus(); }, 60);
        }
        function closeReprint() { dlg.style.display = 'none'; reprintTarget = null; }

        // 长按：触摸与鼠标双路径；期间移动则取消（避免与滚动冲突）
        grid.addEventListener('touchstart', function (ev) {
          if (ev.target.tagName !== 'IMG') return;
          var img = ev.target;
          pressTimer = setTimeout(function () { openReprint(img); }, 800);
        }, { passive: true });
        grid.addEventListener('touchmove', function () { clearTimeout(pressTimer); }, { passive: true });
        grid.addEventListener('touchend', function () { clearTimeout(pressTimer); });
        grid.addEventListener('mousedown', function (ev) {
          if (ev.target.tagName !== 'IMG') return;
          var img = ev.target;
          pressTimer = setTimeout(function () { openReprint(img); }, 800);
        });
        ['mousemove', 'mouseup', 'mouseleave'].forEach(function (e) {
          grid.addEventListener(e, function () { clearTimeout(pressTimer); });
        });

        document.getElementById('reprint-cancel').addEventListener('click', closeReprint);
        dlg.addEventListener('click', function (ev) { if (ev.target === dlg) closeReprint(); });
        document.getElementById('reprint-go').addEventListener('click', function () {
          if (!reprintTarget) return;
          var code = dlgCode.value.trim();
          if (!code) { dlgCode.focus(); return; }
          var payload = JSON.stringify({ type: 'reprint', code: code,
                                         date: reprintTarget.date, session: reprintTarget.session });
          reprintWS.send(payload);
          closeReprint();
        });
        dlgCode.addEventListener('keydown', function (ev) {
          if (ev.key === 'Enter') document.getElementById('reprint-go').click();
        });

        // 重打指令走独立 WS（gallery 页无主控状态流）
        var reprintWS = null;
        (function connectWS() {
          try { reprintWS = new WebSocket('ws://' + location.host + '/ws'); }
          catch (e) { setTimeout(connectWS, 3000); return; }
          reprintWS.onclose = function () { setTimeout(connectWS, 3000); };
          reprintWS.onerror = function () { try { reprintWS.close(); } catch (e) {} };
        })();

        fetchPhotos().then(render);
        setTimeout(function () { fetchPhotos().then(render); }, 60000);
        """# + fetchScript)

    /// iPad 独立放映页：全屏轮播历史成片（点击暂停/继续，秒间隔跟随服务端配置注入）
    static func slideshowHTML(intervalSec: Int) -> String {
        pageShell(
            title: "<img class=\"tic\" src=\"/theme/icon/film.png\" onerror=\"this.outerHTML='🎞️'\"> LUMIX 放映",
            bodyHTML: #"""
            <div id="slide"></div>
            <div class="empty" id="empty" style="display:none">
              <span class="emoji"><img class="eic" src="/theme/icon/mailbox.png" onerror="this.outerHTML='📭'"></span>还没有成片可放映
            </div>
            <style>
              #slide { display:none; align-items:center; justify-content:center; height:100%; }
              #slide img { max-width:96vw; max-height:88vh; border-radius:28px;
                           border:10px solid #fff; box-shadow:0 18px 60px rgba(91,74,79,.35); }
              #pause { position:fixed; bottom:22px; left:0; right:0; text-align:center;
                       font-size:16px; opacity:.55; }
            </style>
            <div id="slide"><img id="slide-img" alt="放映"></div>
            <div id="pause">点击屏幕 暂停 / 继续</div>
            """#,
            script: #"""
            var INTERVAL = \#(max(2, intervalSec)) * 1000;
            var slide = document.getElementById('slide');
            var slideImg = document.getElementById('slide-img');
            var photos = [], idx = 0, timer = null, paused = false;

            function show() {
              if (!photos.length) return;
              idx = (idx + 1) % photos.length;
              slideImg.src = photos[idx].url;
            }

            function start() {
              if (timer || !photos.length) return;
              slideImg.src = photos[0].url;
              slide.style.display = 'flex';
              timer = setInterval(show, INTERVAL);
            }

            function stop() { clearInterval(timer); timer = null; }

            document.body.addEventListener('click', function () {
              if (!photos.length) return;
              paused = !paused;
              if (paused) { stop(); } else { start(); }
            });

            fetchPhotos().then(function (list) {
              photos = list;
              if (photos.length) { start(); }
              else { document.getElementById('empty').style.display = 'block'; }
            });
            setTimeout(function () {
              fetchPhotos().then(function (list) {
                if (list.length && !photos.length) { photos = list; start(); }
              });
            }, 60000);
            """# + fetchScript)
    }

    // MARK: - 视频留言簿（婚礼场景）

    /// /guestbook 录制页：大按钮开始/停止 + 时长进度 + 留言列表回放
    static func guestbookHTML(maxDurationSec: Int, overlayText: String) -> String {
        pageShell(
            title: "💌 留言簿",
            bodyHTML: #"""
            <div id="gb-main">
              <div id="overlay-text"></div>
              <div class="big-btn" id="btn-record">按下开始<br>录制祝福</div>
              <div id="rec-state"></div>
              <div id="rec-bar"><div id="rec-fill"></div></div>
            </div>
            <div id="gb-list"></div>
            <style>
              #gb-main { padding:64px 20px 10px; text-align:center; position:relative; }
              .big-btn { display:inline-block; width:220px; height:220px; border-radius:50%;
                         background:#FF8FAB; color:#fff; font-size:26px; font-weight:700;
                         line-height:1.5; padding-top:78px; margin-top:24px;
                         box-shadow:0 12px 34px rgba(255,143,171,.45); }
              .big-btn.rec { background:#E74C3C; box-shadow:0 12px 34px rgba(231,76,60,.5); }
              #rec-state { font-size:20px; margin-top:16px; color:#5B4A4F; }
              #rec-bar { width:260px; height:8px; background:#F1EAE6; border-radius:4px;
                         margin:12px auto 0; overflow:hidden; display:none; }
              #rec-fill { height:100%; width:0%; background:#E74C3C; }
              #overlay-text { position:absolute; top:16px; left:0; right:0; font-size:22px;
                              font-weight:700; color:#FF8FAB; letter-spacing:4px; }
              #gb-list { padding:10px 20px 30px; }
              #gb-list h3 { text-align:center; font-size:18px; margin:18px 0 10px; }
              #gb-list video { display:block; width:100%; border-radius:16px; margin-bottom:14px;
                                background:#000; }
            </style>
            """#,
            script: #"""
            var MAXSEC = \#(max(5, maxDurationSec));
            var OVERLAY = "\#(overlayText)";
            var btn = document.getElementById('btn-record');
            var state = document.getElementById('rec-state');
            var bar = document.getElementById('rec-bar');
            var fill = document.getElementById('rec-fill');
            var recTimer = null, recStart = 0, recording = false;

            if (OVERLAY) { document.getElementById('overlay-text').textContent = '“' + OVERLAY + '”'; }

            btn.addEventListener('click', function () { recording ? doStop() : doStart(); });

            function doStart() {
              fetch('/guestbook/start', { method: 'POST' })
                .then(function (r) { return r.json(); })
                .then(function (d) {
                  if (!d.ok) { state.textContent = d.error || '启动失败'; return; }
                  recording = true;
                  btn.classList.add('rec');
                  btn.innerHTML = '按下<br>结束录制';
                  bar.style.display = 'block';
                  recStart = Date.now();
                  tickRec();
                  recTimer = setInterval(tickRec, 200);
                })
                .catch(function () { state.textContent = '网络错误，稍后再试'; });
            }

            function tickRec() {
              var elapsed = (Date.now() - recStart) / 1000;
              var left = Math.max(0, MAXSEC - elapsed);
              state.textContent = '录制中… 剩余 ' + Math.ceil(left) + ' 秒';
              fill.style.width = Math.min(100, elapsed / MAXSEC * 100) + '%';
              if (left <= 0) doStop();
            }

            function doStop() {
              clearInterval(recTimer); recTimer = null;
              fetch('/guestbook/stop', { method: 'POST' })
                .then(function (r) { return r.json(); })
                .then(function (d) {
                  recording = false;
                  btn.classList.remove('rec');
                  btn.innerHTML = '按下开始<br>录制祝福';
                  bar.style.display = 'none';
                  fill.style.width = '0%';
                  state.textContent = d.ok ? '✅ 已保存，感谢祝福！' : (d.error || '已停止');
                  if (d.ok) setTimeout(loadList, 600);
                })
                .catch(function () { recording = false; state.textContent = '网络错误'; });
            }

            function loadList() {
              fetch('/api/guestbook').then(function (r) { return r.json(); })
                .then(function (d) {
                  var list = document.getElementById('gb-list');
                  var vids = d.videos || [];
                  var html = vids.length ? '<h3>👏 已收到 ' + vids.length + ' 条祝福</h3>' : '';
                  list.innerHTML = html + vids.slice(0, 10).map(function (v) {
                    return '<video src="' + v.url + '" controls preload="metadata"></video>';
                  }).join('');
                })
                .catch(function () {});
            }
            loadList();
            """#)
    }
}
