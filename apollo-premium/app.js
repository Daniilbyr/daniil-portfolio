/** Переключение объёма на карточке товара */
(function () {
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
