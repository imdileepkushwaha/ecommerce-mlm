/* ========================
   HERO SLIDER - VERTICAL
   ======================== */
function changeSlide(index) {
    // Update dots
    const dots = document.querySelectorAll('#homeHero .dot');
    dots.forEach((dot, i) => {
        if (i === index) {
            dot.classList.add('active');
        } else {
            dot.classList.remove('active');
        }
    });

    // Slide the track vertically
    const track = document.getElementById('heroTrack');
    // Since each slide is exactly 100% of the container height, we translate by index * -100%
    track.style.transform = `translateY(-${index * 100}%)`;
}

// Smooth sticky header transition
window.addEventListener('scroll', function () {
    var header = document.querySelector('.main-header');
    if (window.scrollY > 50) {
        header.classList.add('sticky-active');
    } else {
        header.classList.remove('sticky-active');
    }
});

/* ========================
   MOBILE OFFCANVAS MENU
   ======================== */
document.addEventListener('DOMContentLoaded', function () {
    const mobileBtn = document.querySelector('.mobile-menu-btn');
    const offcanvas = document.querySelector('.mobile-offcanvas');
    const overlay = document.querySelector('.mobile-overlay');
    const closeBtn = document.querySelector('.offcanvas-close');
    
    const offcanvasBody = document.querySelector('.offcanvas-body');
    const userAction = document.querySelector('.user-action');
    const mainMenu = document.querySelector('.main-menu');
    const bottomNav = document.querySelector('.bottom-nav .container');
    const headerRightActions = document.querySelector('.header-right-actions');

    // Toggle menu
    function openMenu() {
        offcanvas.classList.add('active');
        overlay.classList.add('active');
    }

    function closeMenu() {
        offcanvas.classList.remove('active');
        overlay.classList.remove('active');
    }

    if (mobileBtn) mobileBtn.addEventListener('click', openMenu);
    if (closeBtn) closeBtn.addEventListener('click', closeMenu);
    if (overlay) overlay.addEventListener('click', closeMenu);

    // Handle Resize (move elements)
    function handleResize() {
        if (window.innerWidth <= 768) {
            // Move User Action to Offcanvas
            if (userAction && !userAction.classList.contains('in-offcanvas')) {
                offcanvasBody.appendChild(userAction);
                userAction.classList.add('in-offcanvas');
            }
            // Move Main Menu to Offcanvas
            if (mainMenu && !mainMenu.classList.contains('in-offcanvas')) {
                offcanvasBody.appendChild(mainMenu);
                mainMenu.classList.add('in-offcanvas');
            }
        } else {
            // Restore User Action to Desktop
            if (userAction && userAction.classList.contains('in-offcanvas')) {
                headerRightActions.insertBefore(userAction, headerRightActions.firstChild);
                userAction.classList.remove('in-offcanvas');
            }
            // Restore Main Menu to Desktop
            if (mainMenu && mainMenu.classList.contains('in-offcanvas')) {
                // Assuming it goes into .shop-categories sibling or container
                if(bottomNav) bottomNav.appendChild(mainMenu);
                mainMenu.classList.remove('in-offcanvas');
            }
        }
    }

    window.addEventListener('resize', handleResize);
    handleResize(); // Run on load

    /* ========================
       TOP CATEGORIES SLIDER
       ======================== */
    const catTrack = document.getElementById('categorySliderTrack');
    const catPrev = document.querySelector('.prev-cat');
    const catNext = document.querySelector('.next-cat');
    
    if(catTrack && catPrev && catNext) {
        let currentCatIndex = 0;
        
        function slideCategories(direction) {
            const items = catTrack.querySelectorAll('.category-item-container');
            if(!items.length) return;
            
            // To get accurate step, measure distance between start of item 1 and item 2
            let step = 252; // Fallback
            if(items.length > 1) {
                step = items[1].offsetLeft - items[0].offsetLeft;
            }
            
            // How many items can we slide?
            // Depends on visible area width
            const visibleWidth = catTrack.parentElement.offsetWidth;
            const trackScrollWidth = catTrack.scrollWidth;
            
            // Calculate max offset
            const maxOffset = trackScrollWidth - visibleWidth;
            
            // Calculate current translation
            let currentOffset = currentCatIndex * step;
            
            if(direction === 'next') {
                if(currentOffset + step < maxOffset) {
                    currentCatIndex++;
                } else {
                    // Snap to end if there's a little bit left
                    currentCatIndex++;
                    // limit it properly or let it slide normally
                }
                
                // Let's just do simple index
                // Check if we hit the end
                if (currentCatIndex >= items.length) {
                    currentCatIndex = items.length - 1;
                }
            } else if (direction === 'prev') {
                currentCatIndex--;
                if(currentCatIndex < 0) currentCatIndex = 0;
            }
            
            // To prevent scrolling past the end empty space
            let targetOffset = currentCatIndex * step;
            if (targetOffset > maxOffset && maxOffset > 0) {
                targetOffset = maxOffset;
            }
            
            catTrack.style.transform = `translateX(-${targetOffset}px)`;
        }

        catNext.addEventListener('click', () => slideCategories('next'));
        catPrev.addEventListener('click', () => slideCategories('prev'));
    }
});