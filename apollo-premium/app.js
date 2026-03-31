(function () {
  'use strict';

  document.querySelectorAll('[data-reveal]').forEach(function (el) {
    el.classList.add('is-visible');
  });

  var priceMain = document.getElementById('pdp-price-main');
  var priceSticky = document.getElementById('pdp-price-sticky');

  function getActiveSizePrice() {
    var active = document.querySelector('.size-row .size.size--active');
    if (!active) return 158;
    var p = active.getAttribute('data-price');
    return parseInt(p, 10) || 158;
  }

  function getConcOffset() {
    var active = document.querySelector('.concentration-row .conc.conc--active');
    if (!active) return 0;
    var o = active.getAttribute('data-price-offset');
    return parseInt(o, 10) || 0;
  }

  function updateDisplayedPrices() {
    var total = getActiveSizePrice() + getConcOffset();
    if (priceMain) priceMain.textContent = String(total);
    if (priceSticky) priceSticky.textContent = String(total);
  }

  document.querySelectorAll('.size-row').forEach(function (row) {
    row.querySelectorAll('.size').forEach(function (btn) {
      btn.addEventListener('click', function () {
        row.querySelectorAll('.size').forEach(function (s) {
          s.classList.remove('size--active');
          s.setAttribute('aria-checked', 'false');
        });
        btn.classList.add('size--active');
        btn.setAttribute('aria-checked', 'true');
        updateDisplayedPrices();
      });
    });
  });

  document.querySelectorAll('.concentration-row').forEach(function (row) {
    row.querySelectorAll('.conc').forEach(function (btn) {
      btn.addEventListener('click', function () {
        row.querySelectorAll('.conc').forEach(function (c) {
          c.classList.remove('conc--active');
          c.setAttribute('aria-checked', 'false');
        });
        btn.classList.add('conc--active');
        btn.setAttribute('aria-checked', 'true');
        updateDisplayedPrices();
      });
    });
  });

  document.querySelectorAll('.icon-fav').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var pressed = btn.getAttribute('aria-pressed') === 'true';
      btn.setAttribute('aria-pressed', pressed ? 'false' : 'true');
    });
  });

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

  var sticky = document.getElementById('pdp-sticky');
  var mainCta = document.getElementById('main-cta');
  var mq = window.matchMedia('(max-width: 768px)');

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
          setStickyVisible(!entry.isIntersecting);
        });
      },
      { root: null, threshold: 0, rootMargin: '0px 0px 8px 0px' }
    );
    ioCta.observe(mainCta);
    mq.addEventListener('change', function () {
      if (!mq.matches) setStickyVisible(false);
    });
  }

  var stickyBtn = document.querySelector('.pdp-sticky__btn');
  if (stickyBtn && mainCta) {
    stickyBtn.addEventListener('click', function () {
      mainCta.click();
    });
  }

  updateDisplayedPrices();
})();
