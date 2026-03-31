(function () {
  var cfg = window.CALC_CONFIG;
  var state = {
    step: 0,
    area: null,
    work: [],
    urgency: null,
  };

  var steps = [
    { id: 'welcome', render: renderWelcome },
    { id: 'area', render: renderArea },
    { id: 'work', render: renderWork },
    { id: 'urgency', render: renderUrgency },
    { id: 'result', render: renderResult },
  ];

  var stage = document.getElementById('stage');
  var btnBack = document.getElementById('btnBack');
  var progressBar = document.getElementById('progressBar');

  function setProgress() {
    var p = (state.step / (steps.length - 1)) * 100;
    progressBar.style.width = p + '%';
    progressBar.parentElement.setAttribute('aria-valuenow', Math.round(p));
  }

  function icon(name) {
    var ns = 'http://www.w3.org/2000/svg';
    var svg = document.createElementNS(ns, 'svg');
    svg.setAttribute('class', 'ico');
    svg.setAttribute('viewBox', '0 0 48 48');
    svg.setAttribute('aria-hidden', 'true');
    var p;
    if (name === 'home') {
      p = document.createElementNS(ns, 'path');
      p.setAttribute(
        'd',
        'M10 22 L24 10 L38 22 V38 H10 Z M18 38 V28 H30 V38'
      );
    } else if (name === 'tool') {
      p = document.createElementNS(ns, 'path');
      p.setAttribute('d', 'M14 34 L28 20 L32 24 L18 38 Z M30 18 L34 14 L36 16 L32 20');
    } else if (name === 'clock') {
      p = document.createElementNS(ns, 'path');
      p.setAttribute('d', 'M24 10 A14 14 0 1 1 23.99 10 M24 18 V24 L30 28');
    } else {
      p = document.createElementNS(ns, 'circle');
      p.setAttribute('cx', '24');
      p.setAttribute('cy', '24');
      p.setAttribute('r', '14');
    }
    p.setAttribute('fill', 'none');
    p.setAttribute('stroke', 'currentColor');
    p.setAttribute('stroke-width', '2');
    p.setAttribute('stroke-linecap', 'round');
    p.setAttribute('stroke-linejoin', 'round');
    svg.appendChild(p);
    return svg;
  }

  function renderWelcome() {
    var wrap = document.createElement('div');
    wrap.className = 'slide';
    wrap.innerHTML =
      '<h1 class="slide__title">' +
      esc(cfg.copy.title) +
      '</h1>' +
      '<p class="slide__lead">' +
      esc(cfg.copy.intro) +
      '</p>' +
      '<button type="button" class="btn btn--primary" id="startBtn">Начать</button>';
    stage.appendChild(wrap);
    document.getElementById('startBtn').addEventListener('click', function () {
      state.step = 1;
      go();
    });
  }

  function renderArea() {
    var wrap = document.createElement('div');
    wrap.className = 'slide';
    var h = document.createElement('h2');
    h.className = 'slide__title';
    h.textContent = 'Площадь объекта';
    wrap.appendChild(h);
    var grid = document.createElement('div');
    grid.className = 'pick-grid';
    cfg.options.area.forEach(function (opt) {
      var b = document.createElement('button');
      b.type = 'button';
      b.className = 'pick pick--card';
      b.dataset.id = opt.id;
      b.innerHTML =
        '<span class="pick__ico"></span><span class="pick__label">' + esc(opt.label) + '</span>';
      b.querySelector('.pick__ico').appendChild(icon('home'));
      b.addEventListener('click', function () {
        state.area = opt;
        state.step = 2;
        go();
      });
      grid.appendChild(b);
    });
    wrap.appendChild(grid);
    stage.appendChild(wrap);
  }

  function renderWork() {
    var wrap = document.createElement('div');
    wrap.className = 'slide';
    var h = document.createElement('h2');
    h.className = 'slide__title';
    h.textContent = 'Какие работы нужны? (можно несколько)';
    wrap.appendChild(h);
    var grid = document.createElement('div');
    grid.className = 'pick-grid pick-grid--multi';
    cfg.options.work.forEach(function (opt) {
      var b = document.createElement('button');
      b.type = 'button';
      b.className = 'pick pick--card pick--toggle';
      b.dataset.id = opt.id;
      b.setAttribute('aria-pressed', 'false');
      b.innerHTML =
        '<span class="pick__ico"></span><span class="pick__label">' + esc(opt.label) + '</span>';
      b.querySelector('.pick__ico').appendChild(icon('tool'));
      b.addEventListener('click', function () {
        var on = b.getAttribute('aria-pressed') === 'true';
        b.setAttribute('aria-pressed', on ? 'false' : 'true');
        b.classList.toggle('is-on', !on);
      });
      grid.appendChild(b);
    });
    var next = document.createElement('button');
    next.type = 'button';
    next.className = 'btn btn--primary slide__next';
    next.textContent = 'Далее';
    next.addEventListener('click', function () {
      state.work = [];
      grid.querySelectorAll('.pick--toggle[aria-pressed="true"]').forEach(function (el) {
        var id = el.dataset.id;
        cfg.options.work.forEach(function (o) {
          if (o.id === id) state.work.push(o);
        });
      });
      if (state.work.length === 0) {
        state.work = [cfg.options.work[0]];
      }
      state.step = 3;
      go();
    });
    wrap.appendChild(grid);
    wrap.appendChild(next);
    stage.appendChild(wrap);
  }

  function renderUrgency() {
    var wrap = document.createElement('div');
    wrap.className = 'slide';
    var h = document.createElement('h2');
    h.className = 'slide__title';
    h.textContent = 'Сроки';
    wrap.appendChild(h);
    var grid = document.createElement('div');
    grid.className = 'pick-grid';
    cfg.options.urgency.forEach(function (opt) {
      var b = document.createElement('button');
      b.type = 'button';
      b.className = 'pick pick--card';
      b.innerHTML =
        '<span class="pick__ico"></span><span class="pick__label">' + esc(opt.label) + '</span>';
      b.querySelector('.pick__ico').appendChild(icon('clock'));
      b.addEventListener('click', function () {
        state.urgency = opt;
        state.step = 4;
        go();
      });
      grid.appendChild(b);
    });
    wrap.appendChild(grid);
    stage.appendChild(wrap);
  }

  function calcTotal() {
    var mult = state.area ? state.area.multiplier : 1;
    var workSum = 0;
    state.work.forEach(function (w) {
      workSum += w.price;
    });
    var urg = state.urgency ? state.urgency.factor : 1;
    return Math.round((cfg.baseFee + workSum) * mult * urg);
  }

  function renderResult() {
    var total = calcTotal();
    var wrap = document.createElement('div');
    wrap.className = 'slide slide--result';
    wrap.innerHTML =
      '<h2 class="slide__title">' +
      esc(cfg.copy.resultTitle) +
      '</h2>' +
      '<p class="result__sum"><span class="result__num">' +
      total.toLocaleString('en-AE') +
      '</span> <span class="result__cur">' +
      esc(cfg.currency) +
      '</span></p>' +
      '<p class="slide__muted">' +
      esc(cfg.copy.disclaimer) +
      '</p>' +
      '<button type="button" class="btn btn--ghost" id="againBtn">Пройти снова</button>';
    stage.appendChild(wrap);
    document.getElementById('againBtn').addEventListener('click', function () {
      state.step = 0;
      state.area = null;
      state.work = [];
      state.urgency = null;
      go();
    });
  }

  function esc(s) {
    var d = document.createElement('div');
    d.textContent = s;
    return d.innerHTML;
  }

  function go() {
    stage.innerHTML = '';
    setProgress();
    btnBack.hidden = state.step === 0 || state.step === 4;
    steps[state.step].render();
  }

  btnBack.addEventListener('click', function () {
    if (state.step > 0 && state.step < 4) {
      state.step -= 1;
      go();
    }
  });

  go();
})();
