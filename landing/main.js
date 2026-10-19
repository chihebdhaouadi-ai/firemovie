(() => {
  const root = document.documentElement;
  root.classList.remove('no-js');
  root.classList.add('js');

  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  const INTRO_MS = 2200;
  const SEEN_KEY = 'fw-intro-seen';

  const intro = document.getElementById('intro');
  const skip = document.getElementById('intro-skip');
  const page = document.getElementById('page');
  const sticky = document.getElementById('sticky-cta');

  const readSeen = () => {
    try {
      return sessionStorage.getItem(SEEN_KEY) === '1';
    } catch (error) {
      return false;
    }
  };

  const writeSeen = () => {
    try {
      sessionStorage.setItem(SEEN_KEY, '1');
    } catch (error) {
      return;
    }
  };

  let introTimer = 0;

  const endIntro = () => {
    if (!intro || intro.hidden) return;
    clearTimeout(introTimer);
    document.removeEventListener('keydown', onIntroKey);
    intro.hidden = true;
    page.inert = false;
    writeSeen();
  };

  const onIntroKey = (event) => {
    if (event.key === 'Escape') endIntro();
  };

  if (intro && page && !reduceMotion.matches && !readSeen()) {
    intro.hidden = false;
    page.inert = true;
    skip.focus();
    document.addEventListener('keydown', onIntroKey);
    introTimer = setTimeout(endIntro, INTRO_MS);
    skip.addEventListener('click', endIntro);
  }

  const reveals = document.querySelectorAll('[data-reveal]');
  if ('IntersectionObserver' in window && !reduceMotion.matches) {
    const revealObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('is-in');
        observer.unobserve(entry.target);
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -8% 0px' });
    reveals.forEach((el) => revealObserver.observe(el));
  } else {
    reveals.forEach((el) => el.classList.add('is-in'));
  }

  const hero = document.getElementById('top');
  const finalCta = document.getElementById('get-app');
  const visibility = { heroOut: false, finalIn: false };

  const syncSticky = () => {
    const show = visibility.heroOut && !visibility.finalIn;
    sticky.classList.toggle('is-visible', show);
    sticky.inert = !show;
  };

  if (sticky && hero && finalCta && 'IntersectionObserver' in window) {
    sticky.inert = true;
    const stickyObserver = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.target === hero) visibility.heroOut = !entry.isIntersecting;
        if (entry.target === finalCta) visibility.finalIn = entry.isIntersecting;
      });
      syncSticky();
    });
    stickyObserver.observe(hero);
    stickyObserver.observe(finalCta);
  }
})();
