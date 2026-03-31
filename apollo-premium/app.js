(function () {
  'use strict';

  /** Unsplash → Picsum → локальный SVG в /apollo-premium/img/ */
  document.querySelectorAll('img.js-img-fallback').forEach(function (img) {
    img.addEventListener('error', function onErr() {
      var u = img.src || '';
      if (u.indexOf('placeholder-') !== -1) {
        return;
      }

      var fb = img.getAttribute('data-fallback');
      var loc = img.getAttribute('data-local');

      if (fb && u.indexOf('picsum.photos') === -1) {
        img.src = fb;
        return;
      }

      if (loc) {
        try {
          img.src = new URL(loc, window.location.href).href;
        } catch (e) {
          img.src = loc;
        }
      }
    });
  });

  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var nodes = document.querySelectorAll('[data-reveal]');

  function revealEl(el) {
    el.classList.add('is-visible');
  }

  function revealVisibleNow() {
    nodes.forEach(function (el) {
      var r = el.getBoundingClientRect();
      if (r.top < window.innerHeight * 1.08 && r.bottom > -40) {
        revealEl(el);
      }
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

  document.querySelectorAll('.size-row').forEach(function (row) {
    row.querySelectorAll('.size').forEach(function (btn) {
      btn.addEventListener('click', function () {
        row.querySelectorAll('.size').forEach(function (s) {
          s.classList.remove('size--active');
        });
        btn.classList.add('size--active');
      });
    });
  });
})();
