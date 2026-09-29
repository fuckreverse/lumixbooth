import Foundation

// ============================================================
// iPad 单页应用（GET / 的响应体）
//  - 全部内嵌为 Swift 字符串常量，零静态资源文件
//  - vanilla JS，无框架；MJPEG 用 <img src="/live">（Safari 原生支持）
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

          /* 连接指示点 */
          .dot { position:fixed; top:18px; left:18px; width:16px; height:16px; border-radius:50%;
                 background:#D8CCC6; z-index:9; transition:background .3s; }
          .dot.on { background:#7BC47F; box-shadow:0 0 14px #7BC47F; }

          /* 顶部 LiveView 小窗（点击可收起/展开；成片确认与打印时自动隐藏） */
          #livebox { position:fixed; top:14px; right:14px; width:184px; border-radius:18px; overflow:hidden;
                     border:5px solid #fff; box-shadow:0 10px 26px rgba(91,74,79,.22); z-index:8;
                     background:#fff; }
          #livebox img { display:block; width:100%; min-height:70px; }
          #livebox.hidden, body.review #livebox, body.printing #livebox, body.countdown #livebox { display:none; }

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
          .filter-btn.on { border-color:var(--peach); color:var(--peach);
                           box-shadow:0 8px 18px rgba(255,143,171,.35); }

          /* 待机页底部入口（相册 / 放映） */
          .links { position:fixed; bottom:16px; left:0; right:0; text-align:center; font-size:17px; }
          .links a { color:var(--peach); text-decoration:none; font-weight:700; margin:0 12px;
                     -webkit-touch-callout:none; }

          .fail { background:#FFE3E3; color:#C0392B; border-radius:24px; padding:26px 38px; font-size:24px; }
        </style>
        </head>
        <body>
          <div id="dot" class="dot"></div>
          <header>LUMIX 拍照屋</header>
          <div id="livebox"><img id="liveimg" alt="实时取景" src="/live"></div>
          <main><div class="card" id="stage"></div></main>
          <div class="links"><a href="/gallery"><img class="tic" src="/theme/icon/album.png" onerror="this.outerHTML='📖'"> 相册</a><a href="/slideshow"><img class="tic" src="/theme/icon/film.png" onerror="this.outerHTML='🎞️'"> 放映</a></div>

        <script>
        var ws = null, cur = null, copies = 2, modeKind = 'collage', takeTimer = null;
        var filters = null, curFilter = 'none', showPrint = true;

        var dot     = document.getElementById('dot');
        var stage   = document.getElementById('stage');
        var livebox = document.getElementById('livebox');
        var liveimg = document.getElementById('liveimg');

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
          document.body.classList.toggle('review',    s === 'review');
          document.body.classList.toggle('printing',  s === 'printing');
          document.body.classList.toggle('countdown', s === 'countdown');
          if (takeTimer) { clearTimeout(takeTimer); takeTimer = null; }

          if (s === 'countdown') {
            stage.innerHTML = '<div class="countdown">' + (m.secondsLeft || 0) + '</div>';
            return;
          }
          if (s === 'review' && m.photoId) {
            copies = m.copies || 2;
            if (m.filters) { filters = m.filters; }
            if (typeof m.showPrint === 'boolean') { showPrint = m.showPrint; }
            if (cur !== 'review') { curFilter = 'none'; }   // 新一轮流程回到原片
            renderReview(m.photoId);
            return;
          }
          var map = {
            idle:       ['camera', '📸', '看镜头准备拍照'],
            armed:      ['smile', '😊', '站好啦，看镜头'],
            gestureWait:['peace', '✌️', '比个耶，开始拍照！'],
            capturing:  ['camera', '📷', '拍摄中'],
            processing: ['sparkle', '✨', '正在修图'],
            printing:   ['printer', '🖨️', '打印中，请稍候']
          };
          if (map[s]) {
            var sub = '';
            if (s === 'capturing' && m.shot && m.of) sub = '第 ' + m.shot + ' / ' + m.of + ' 张';
            if (s === 'printing' && m.copies)       sub = '共 ' + m.copies + ' 张';
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
          stage.innerHTML =
            '<img class="photo" src="/photo/' + photoId + '?t=' + Date.now() + '">' +
            filterRow +
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
          if (!b) return;
          if (b.dataset.kind) { pickMode(b.dataset.kind); return; }
          if (b.dataset.filter) { pickFilter(b.dataset.filter); return; }
          if (b.id === 'cop-minus') { copies = Math.max(1, copies - 1); }
          if (b.id === 'cop-plus')  { copies = Math.min(4, copies + 1); }
          if (b.id === 'cop-minus' || b.id === 'cop-plus') {
            var n = document.getElementById('cop-num');
            if (n) n.textContent = copies;
            return;
          }
          if (b.id === 'btn-print')  { send({ type: 'print', copies: copies }); }
          if (b.id === 'btn-retake') { send({ type: 'retake' }); }
        });

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
          <header>\#(title)<br><a href="/">← 回拍照确认屏</a></header>
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
        <style>
          #grid { display:grid; grid-template-columns:repeat(2,1fr); gap:14px; padding:14px; }
          #grid img { width:100%; display:block; border-radius:18px; border:6px solid #fff;
                      box-shadow:0 8px 22px rgba(91,74,79,.18); }
          #lightbox { position:fixed; inset:0; background:rgba(91,74,79,.92); display:none;
                      align-items:center; justify-content:center; z-index:9; }
          #lightbox img { max-width:94vw; max-height:92vh; border-radius:24px;
                          border:8px solid #fff; }
        </style>
        <div id="lightbox"><img id="lightbox-img" alt="成片大图"></div>
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
            return '<img src="' + p.url + '" loading="lazy" data-full="' + p.url + '" alt="成片">';
          }).join('');
        }

        grid.addEventListener('click', function (ev) {
          if (ev.target.tagName !== 'IMG') return;
          lightboxImg.src = ev.target.dataset.full;
          lightbox.style.display = 'flex';
        });
        lightbox.addEventListener('click', function () { lightbox.style.display = 'none'; });

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
}
