(function () {
  'use strict';

  /** Если Unsplash недоступен — подставляем URL из data-fallback (picsum). */
  document.querySelectorAll('img.js-img-fallback').forEach(function (img) {
    img.addEventListener('error', function onError() {
      var fb = img.getAttribute('data-fallback');
      if (fb && img.src.indexOf('picsum.photos') === -1) {
        img.removeEventListener('error', onError);
        img.src = fb;
      }
    });
  });

  /** Плавное появление секций (отключается при prefers-reduced-motion в CSS). */
  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var nodes = document.querySelectorAll('[data-reveal]');

  function revealEl(el) {
    el.classList.add('is-visible');
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
      { root: null, rootMargin: '0px 0px 40px 0px', threshold: 0.06 }
    );
    nodes.forEach(function (el) {
      io.observe(el);
    });
  } else {
    nodes.forEach(revealEl);
  }

  /** Переключение объёма */
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
