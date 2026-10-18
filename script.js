document.addEventListener('DOMContentLoaded', function() {
    console.log('Portfolio page loaded');

    /* ---------- nav scroll-spy ---------- */
    /* only tabs with a data-section correspond to a page section - the
       CV tab is an external link and stays out of the active-tab logic */
    const navTabs = document.querySelectorAll('.nav-tab[data-section]');
    const sectionEls = document.querySelectorAll('main .section');

    const setActive = (id) => {
        navTabs.forEach(tab => {
            tab.classList.toggle('active', tab.dataset.section === id);
        });
    };

    /* the observer tracks which section is "current" by scroll position,
       but the first/last sections can be too short to ever fully enter
       the shrunk observer band (top of page / end of scroll) - so those
       two edges are decided explicitly instead, taking precedence */
    const firstTab = navTabs[0];
    const lastTab = navTabs[navTabs.length - 1];
    let currentSection = firstTab ? firstTab.dataset.section : null;

    const applyActive = () => {
        if (window.scrollY < 40 && firstTab) {
            setActive(firstTab.dataset.section);
            return;
        }
        const atBottom = window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 4;
        if (atBottom && lastTab) {
            setActive(lastTab.dataset.section);
            return;
        }
        setActive(currentSection);
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                currentSection = entry.target.dataset.navSection || entry.target.id;
            }
        });
        applyActive();
    }, { rootMargin: '-45% 0px -50% 0px', threshold: 0 });

    sectionEls.forEach(section => observer.observe(section));

    window.addEventListener('scroll', applyActive);
    applyActive();

    /* Both the name and Home target the sticky nav itself (#top); a sticky
       element always reports its own bounding rect top as 0 (it's
       pinned there), so the browser's native anchor-scroll sees "no
       distance to travel" and does nothing - scroll to the top
       manually instead */
    document.querySelectorAll('.nav a[href="#top"]').forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
            window.scrollTo({ top: 0, behavior: reduceMotion ? 'auto' : 'smooth' });
        });
    });

    /* nav border stays invisible until the page is scrolled, like a
       minimal browser chrome divider that only appears once needed */
    const navEl = document.querySelector('.nav');
    const applyNavScrolled = () => {
        if (navEl) navEl.classList.toggle('is-scrolled', window.scrollY > 8);
    };
    window.addEventListener('scroll', applyNavScrolled);
    applyNavScrolled();
});
