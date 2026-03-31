(function () {
  'use strict';

  /** Запасной src → локальный SVG (без picsum: фиксированные id давали «чужие» фото при блокировке CDN) */
  document.querySelectorAll('img.js-img-fallback').forEach(function (img) {
    img.addEventListener('error', function onErr() {
      var u = img.src || '';
      if (u.indexOf('placeholder-') !== -1) return;
      var fb = img.getAttribute('data-fallback');
      var loc = img.getAttribute('data-local');
      if (fb && fb.trim() && fb.indexOf('picsum.photos') === -1 && u.indexOf('picsum.photos') === -1) {
        img.src = fb;
        return;
      }
      if (loc) {
        try {
          var docBase = document.baseURI || window.location.href;
          img.src = new URL(loc, docBase).href;
        } catch (e) {
          img.src = loc;
        }
      }
    });
  });

  /** Снятие скелетона после загрузки изображения (img или встроенный svg) */
  document.querySelectorAll('img.js-img-load, svg.js-img-load').forEach(function (el) {
    function done() {
      var wrap = el.closest('.js-pdp-media') || el.closest('.js-card-img');
      if (wrap) wrap.classList.add('is-loaded');
    }
    var tag = (el.tagName || '').toUpperCase();
    if (tag === 'IMG' && el.complete && el.naturalWidth) {
      done();
    } else if (tag === 'IMG') {
      el.addEventListener('load', done);
      el.addEventListener('error', done);
    } else {
      requestAnimationFrame(done);
    }
  });

  /** Скролл-ревил */
  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var nodes = document.querySelectorAll('[data-reveal]');

  function revealEl(el) {
    el.classList.add('is-visible');
  }

  function revealVisibleNow() {
    nodes.forEach(function (el) {
      var r = el.getBoundingClientRect();
      if (r.top < window.innerHeight * 1.08 && r.bottom > -40) revealEl(el);
    });
  }

  if (!reduceMotion && 'IntersectionObserver' in window) {
    var io = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            revealEl(entry.target);
            io.unobserve(entry.target);
          }
        });
      },
      { root: null, rootMargin: '0px 0px 80px 0px', threshold: 0 }
    );
    nodes.forEach(function (el) {
      io.observe(el);
    });
    requestAnimationFrame(revealVisibleNow);
  } else {
    nodes.forEach(revealEl);
  }

  /** Размеры и цена */
  var priceMain = document.getElementById('pdp-price-main');
  var priceSticky = document.getElementById('pdp-price-sticky');

  document.querySelectorAll('.size-row').forEach(function (row) {
    row.querySelectorAll('.size').forEach(function (btn) {
      btn.addEventListener('click', function () {
        row.querySelectorAll('.size').forEach(function (s) {
          s.classList.remove('size--active');
          s.setAttribute('aria-checked', 'false');
        });
        btn.classList.add('size--active');
        btn.setAttribute('aria-checked', 'true');
        var p = btn.getAttribute('data-price');
        if (p && priceMain) priceMain.textContent = p;
        if (p && priceSticky) priceSticky.textContent = p;
      });
    });
  });

  /** Избранное */
  document.querySelectorAll('.icon-fav').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var pressed = btn.getAttribute('aria-pressed') === 'true';
      btn.setAttribute('aria-pressed', pressed ? 'false' : 'true');
    });
  });

  /** Аккордеон: один открытый блок или все свернуты */
  document.querySelectorAll('.accordion').forEach(function (root) {
    root.querySelectorAll('.accordion__trigger').forEach(function (trigger) {
      trigger.addEventListener('click', function () {
        var panel = document.getElementById(trigger.getAttribute('aria-controls'));
        var wasOpen = trigger.getAttribute('aria-expanded') === 'true';
        root.querySelectorAll('.accordion__trigger').forEach(function (t) {
          var p = document.getElementById(t.getAttribute('aria-controls'));
          t.setAttribute('aria-expanded', 'false');
          if (p) {
            p.hidden = true;
            p.classList.add('accordion__panel--hidden');
          }
        });
        if (!wasOpen && panel) {
          trigger.setAttribute('aria-expanded', 'true');
          panel.hidden = false;
          panel.classList.remove('accordion__panel--hidden');
        }
      });
    });
  });

  /** Липкая панель: только узкий экран, когда основная CTA вне вьюпорта */
  var sticky = document.getElementById('pdp-sticky');
  var mainCta = document.getElementById('main-cta');
  var mq = window.matchMedia('(max-width: 768px)');

  function syncSticky() {
    if (!sticky || !mainCta) return;
    if (!mq.matches) {
      sticky.hidden = true;
      sticky.setAttribute('aria-hidden', 'true');
      return;
    }
  }

  function setStickyVisible(show) {
    if (!sticky) return;
    sticky.hidden = !show;
    sticky.setAttribute('aria-hidden', show ? 'false' : 'true');
    document.body.classList.toggle('page--sticky-open', show);
  }

  if (sticky && mainCta && 'IntersectionObserver' in window) {
    var ioCta = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (!mq.matches) {
            setStickyVisible(false);
            return;
          }
          var hide = entry.isIntersecting;
          setStickyVisible(!hide);
        });
      },
      { root: null, threshold: 0, rootMargin: '0px 0px 8px 0px' }
    );
    ioCta.observe(mainCta);
    mq.addEventListener('change', function () {
      syncSticky();
      if (!mq.matches) setStickyVisible(false);
    });
    syncSticky();
  }

  document.querySelector('.pdp-sticky__btn') &&
    document.querySelector('.pdp-sticky__btn').addEventListener('click', function () {
      var m = document.getElementById('main-cta');
      if (m) m.click();
    });
})();
