import Foundation

// ============================================================
// iPad 单页应用（GET / 的响应体）
//  - 全部内嵌为 Swift 字符串常量，零静态资源文件
//  - vanilla JS，无框架；MJPEG 用 <img src="/live">（Safari 原生支持）
//  - 视觉风格与 BoothUI 一致：奶油底 #FFF7F0 / 蜜桃粉 #FF8FAB /
//    大圆角 / 大字号，全中文可爱风
//  - WS 协议（与 BoothWebService 对应）：
//     收 {"type":"state","state":"...","secondsLeft":n,"shot":n,"of":n,
//          "photoId":"uuid","copies":n,"message":"..."}
//     发 {"type":"print","copies":n} / {"type":"retake"} /
//         {"type":"mode","kind":"single"|"collage","shots":n}
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

          .fail { background:#FFE3E3; color:#C0392B; border-radius:24px; padding:26px 38px; font-size:24px; }
        </style>
        </head>
        <body>
          <div id="dot" class="dot"></div>
          <header>LUMIX 拍照屋</header>
          <div id="livebox"><img id="liveimg" alt="实时取景" src="/live"></div>
          <main><div class="card" id="stage"></div></main>

        <script>
        var ws = null, cur = null, copies = 2, modeKind = 'collage', takeTimer = null;

        var dot     = document.getElementById('dot');
        var stage   = document.getElementById('stage');
        var livebox = document.getElementById('livebox');
        var liveimg = document.getElementById('liveimg');

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
            renderReview(m.photoId);
            return;
          }
          var map = {
            idle:       ['📸', '看镜头准备拍照'],
            armed:      ['😊', '站好啦，看镜头'],
            gestureWait:['✌️', '比个耶，开始拍照！'],
            capturing:  ['📷', '拍摄中'],
            processing: ['✨', '正在修图'],
            printing:   ['🖨️', '打印中，请稍候']
          };
          if (map[s]) {
            var sub = '';
            if (s === 'capturing' && m.shot && m.of) sub = '第 ' + m.shot + ' / ' + m.of + ' 张';
            if (s === 'printing' && m.copies)       sub = '共 ' + m.copies + ' 张';
            stage.innerHTML =
              '<div class="big-emoji">' + map[s][0] + '</div>' +
              '<div class="big-text">' + map[s][1] + '</div>' +
              (sub ? '<div class="sub">' + sub + '</div>' : '') +
              (s === 'idle' ? modeRow() : '');
            syncModeButtons();
            return;
          }
          if (s === 'failure') {
            stage.innerHTML = '<div class="fail">' + (m.message || '出错了，请稍候') + '</div>';
            return;
          }
          stage.innerHTML = '<div class="big-emoji">📷</div><div class="big-text">LUMIX 拍照屋</div>';
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

        // REVIEW：全屏成片 + 张数步进器（1-4）+ 打印 / 重拍
        function renderReview(photoId) {
          stage.innerHTML =
            '<img class="photo" src="/photo/' + photoId + '">' +
            '<div class="controls">' +
              '<div class="stepper">' +
                '<button id="cop-minus">−</button>' +
                '<span class="num" id="cop-num">' + copies + '</span><span class="unit">张</span>' +
                '<button id="cop-plus">＋</button>' +
              '</div>' +
              '<button class="btn btn-peach" id="btn-print">打印 🖨️</button>' +
              '<button class="btn btn-ghost" id="btn-retake">重拍 🔄</button>' +
            '</div>';
        }

        // 打印完成后：请取照片（8s 后自动回待机）
        function renderTakePhoto() {
          cur = 'takephoto';
          document.body.classList.remove('printing');
          stage.innerHTML =
            '<div class="big-emoji">🎉</div>' +
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
}
