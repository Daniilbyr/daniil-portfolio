/**
 * Демо: плавный скролл, цели Метрики (если ym подключён), отправка формы.
 * Подставьте YM_ID в index.html (счётчик) и сюда тот же номер.
 */
const YM_ID = 0

function reachGoal(name) {
  if (YM_ID && typeof window.ym === 'function') {
    try {
      window.ym(YM_ID, 'reachGoal', name)
    } catch {
      /* no-op */
    }
  }
}

document.querySelectorAll('[data-scroll]').forEach((el) => {
  el.addEventListener('click', (e) => {
    const sel = el.getAttribute('data-scroll')
    if (!sel) return
    e.preventDefault()
    const goal = el.getAttribute('data-goal')
    if (goal) reachGoal(goal)
    document.querySelector(sel)?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  })
})

document.querySelectorAll('[data-goal]').forEach((el) => {
  if (el.tagName === 'BUTTON' && el.hasAttribute('data-scroll')) return
  el.addEventListener('click', () => {
    const goal = el.getAttribute('data-goal')
    if (goal) reachGoal(goal)
  })
})

const form = document.getElementById('lead-form')
const success = document.getElementById('form-success')

form?.addEventListener('submit', (e) => {
  e.preventDefault()
  if (!form.checkValidity()) {
    form.reportValidity()
    return
  }
  reachGoal('form_submit')
  success?.removeAttribute('hidden')
  form.reset()
})
