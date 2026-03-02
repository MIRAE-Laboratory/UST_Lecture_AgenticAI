/* ===== slides-common.js ===== */
/* Lightweight slide navigation: keyboard, touch, URL hash, progress bar */

(function () {
  'use strict';

  let current = 0;
  let slides = [];
  let totalSlides = 0;

  /* ---------- Initialise ---------- */
  function init() {
    slides = Array.from(document.querySelectorAll('.slide'));
    totalSlides = slides.length;
    if (!totalSlides) return;

    // Read initial slide from URL hash
    const hash = parseInt(location.hash.replace('#slide-', ''), 10);
    if (hash >= 1 && hash <= totalSlides) current = hash - 1;

    showSlide(current);
    buildDots();
    updateProgress();

    // Listeners
    document.addEventListener('keydown', onKey);
    addTouchListeners();
    window.addEventListener('hashchange', onHashChange);
  }

  /* ---------- Show Slide ---------- */
  function showSlide(index) {
    slides.forEach(function (s, i) {
      s.classList.toggle('active', i === index);
    });
    current = index;
    updateProgress();
    updateDots();
    updatePageNum();
    history.replaceState(null, '', '#slide-' + (current + 1));
    // Scroll to top of slide content
    slides[current].scrollTop = 0;
    // Callback hook
    if (typeof window.onSlideChange === 'function') window.onSlideChange(current);
  }

  function nextSlide() { if (current < totalSlides - 1) showSlide(current + 1); }
  function prevSlide() { if (current > 0) showSlide(current - 1); }
  function goToSlide(n) { if (n >= 0 && n < totalSlides) showSlide(n); }

  /* ---------- Progress ---------- */
  function updateProgress() {
    var bar = document.querySelector('.progress-bar');
    if (bar) bar.style.width = ((current + 1) / totalSlides * 100) + '%';
  }

  /* ---------- Dots ---------- */
  function buildDots() {
    var container = document.querySelector('.nav-dots');
    if (!container) return;
    container.innerHTML = '';
    for (var i = 0; i < totalSlides; i++) {
      var dot = document.createElement('span');
      dot.className = 'nav-dot' + (i === current ? ' active' : '');
      dot.dataset.index = i;
      dot.addEventListener('click', function () { goToSlide(+this.dataset.index); });
      container.appendChild(dot);
    }
  }

  function updateDots() {
    document.querySelectorAll('.nav-dot').forEach(function (d, i) {
      d.classList.toggle('active', i === current);
    });
  }

  /* ---------- Page Number ---------- */
  function updatePageNum() {
    var el = document.querySelector('.page-num');
    if (el) el.textContent = (current + 1) + ' / ' + totalSlides;
  }

  /* ---------- Keyboard ---------- */
  function onKey(e) {
    if (e.key === 'ArrowRight' || e.key === ' ') { e.preventDefault(); nextSlide(); }
    else if (e.key === 'ArrowLeft') { e.preventDefault(); prevSlide(); }
    else if (e.key === 'Home') { e.preventDefault(); goToSlide(0); }
    else if (e.key === 'End') { e.preventDefault(); goToSlide(totalSlides - 1); }
  }

  /* ---------- Touch ---------- */
  function addTouchListeners() {
    var startX = 0, startY = 0;
    var wrapper = document.querySelector('.slides-wrapper');
    if (!wrapper) return;

    wrapper.addEventListener('touchstart', function (e) {
      startX = e.touches[0].clientX;
      startY = e.touches[0].clientY;
    }, { passive: true });

    wrapper.addEventListener('touchend', function (e) {
      var dx = e.changedTouches[0].clientX - startX;
      var dy = e.changedTouches[0].clientY - startY;
      if (Math.abs(dx) < 50 || Math.abs(dy) > Math.abs(dx)) return;  // too short or vertical
      if (dx < 0) nextSlide(); else prevSlide();
    }, { passive: true });
  }

  /* ---------- Hash ---------- */
  function onHashChange() {
    var hash = parseInt(location.hash.replace('#slide-', ''), 10);
    if (hash >= 1 && hash <= totalSlides) showSlide(hash - 1);
  }

  /* ---------- Global API ---------- */
  window.nextSlide = nextSlide;
  window.prevSlide = prevSlide;
  window.goToSlide = goToSlide;

  /* ---------- Boot ---------- */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
