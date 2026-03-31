(function () {
  'use strict';

  document.querySelectorAll('[data-reveal]').forEach(function (el) {
    el.classList.add('is-visible');
  });

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
})();
