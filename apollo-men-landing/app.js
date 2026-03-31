/**
 * Мобильное меню и переключение выбранного размера (демо).
 */
(function () {
  const burger = document.getElementById('burger');
  const nav = document.getElementById('nav-drawer');
  if (!burger || !nav) return;

  burger.addEventListener('click', function () {
    const open = nav.classList.toggle('is-open');
    burger.setAttribute('aria-expanded', open);
    document.body.style.overflow = open ? 'hidden' : '';
  });

  nav.querySelectorAll('a').forEach(function (link) {
    link.addEventListener('click', function () {
      nav.classList.remove('is-open');
      burger.setAttribute('aria-expanded', 'false');
      document.body.style.overflow = '';
    });
  });

  document.querySelectorAll('.pills').forEach(function (group) {
    group.querySelectorAll('.pill').forEach(function (btn) {
      btn.addEventListener('click', function () {
        group.querySelectorAll('.pill').forEach(function (p) {
          p.classList.remove('pill--active');
        });
        btn.classList.add('pill--active');
      });
    });
  });
})();
