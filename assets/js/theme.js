/* ========================
   HERO SLIDER - VERTICAL WITH AUTOPLAY
   ======================== */
let currentHeroSlide = 0;
const totalHeroSlides = 3;
let autoSlideTimer;

function startHeroAutoplay() {
    clearInterval(autoSlideTimer);
    autoSlideTimer = setInterval(() => {
        currentHeroSlide = (currentHeroSlide + 1) % totalHeroSlides;
        changeSlide(currentHeroSlide, false);
    }, 5000);
}

function changeSlide(index, isManual = true) {
    currentHeroSlide = index;
    const dots = document.querySelectorAll('#homeHero .dot');
    dots.forEach((dot, i) => {
        if (i === index) dot.classList.add('active');
        else dot.classList.remove('active');
    });

    const track = document.getElementById('heroTrack');
    if(track) track.style.transform = "translateY(-" + (index * 100) + "%)";

    if (isManual) startHeroAutoplay();
}

document.addEventListener('DOMContentLoaded', function() {
    if(document.getElementById('heroTrack')) startHeroAutoplay();
});

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
                if (bottomNav) bottomNav.appendChild(mainMenu);
                mainMenu.classList.remove('in-offcanvas');
            }
        }
    }

    window.addEventListener('resize', handleResize);
    handleResize(); // Run on load


});


/* ========================
   COUNTDOWN TIMER LOGIC
   ======================== */
function startCountdown() {
    const dealDays = document.getElementById('deal-days');
    if (!dealDays) return; // Halt if timer does not exist on current page

    const targetDate = new Date();
    targetDate.setDate(targetDate.getDate() + 5);
    targetDate.setHours(23, 59, 59, 999);

    function updateTime() {
        const now = new Date().getTime();
        const distance = targetDate - now;

        if (distance < 0) {
            clearInterval(x);
            document.getElementById('deal-days').innerText = '00';
            document.getElementById('deal-hours').innerText = '00';
            document.getElementById('deal-mins').innerText = '00';
            document.getElementById('deal-secs').innerText = '00';
            return;
        }

        const d = Math.floor(distance / (1000 * 60 * 60 * 24));
        const h = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const m = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        const s = Math.floor((distance % (1000 * 60)) / 1000);

        document.getElementById('deal-days').innerText = d < 10 ? '0' + d : d;
        document.getElementById('deal-hours').innerText = h < 10 ? '0' + h : h;
        document.getElementById('deal-mins').innerText = m < 10 ? '0' + m : m;
        document.getElementById('deal-secs').innerText = s < 10 ? '0' + s : s;
    }

    const x = setInterval(updateTime, 1000);
    updateTime();
}

document.addEventListener('DOMContentLoaded', startCountdown);



/* ========================
   SITE SLIDERS INITIALIZATION
   ======================== */
$(document).ready(function() {
    // 2. Testimonial Carousel
    var $tSlider = $('.testimonial-slider-wrapper');
    if ($tSlider.length > 0 && !$tSlider.hasClass('slick-initialized')) {
        $tSlider.slick({
            dots: true,
            infinite: true,
            speed: 600,
            slidesToShow: 3,
            slidesToScroll: 1,
            autoplay: true,
            autoplaySpeed: 3000,
            arrows: false,
            responsive: [
                { breakpoint: 1024, settings: { slidesToShow: 2, slidesToScroll: 1 } },
                { breakpoint: 600, settings: { slidesToShow: 1, slidesToScroll: 1 } }
            ]
        });
    }
});


/* ========================
   ECOMMERCE STATE LOGIC (CART & WISHLIST)
   ======================== */

document.addEventListener('DOMContentLoaded', function() {
    // 1. Initialize state from LocalStorage or default
    let cartCount = parseInt(localStorage.getItem('ecomm_cart_count')) || 0;
    let wishCount = parseInt(localStorage.getItem('ecomm_wishlist_count')) || 0;

    // Function to sync UI with State
    function updateHeaderCounters() {
        const cartEl = document.getElementById('cart-count');
        const wishEl = document.getElementById('wishlist-count');
        if(cartEl) cartEl.innerText = cartCount;
        if(wishEl) wishEl.innerText = wishCount;
    }

    // Sync on Load
    updateHeaderCounters();

    // 2. Setup Dynamic Click Listeners via Event Delegation
    document.body.addEventListener('click', function(e) {
        
        // -- CASE: WISHLIST HEART CLICKED --
        let wishBtn = e.target.closest('.action-btn[title="Add to Wishlist"]');
        if (wishBtn) {
            e.preventDefault();
            let icon = wishBtn.querySelector('i');
            
            // Toggle active visual state
            if (icon.classList.contains('far')) {
                // ADDING
                icon.classList.replace('far', 'fas');
                icon.style.color = '#f43f5e'; // Force Red
                wishCount++;
                showFeedbackToast('Added to Wishlist!');
            } else {
                // REMOVING
                icon.classList.replace('fas', 'far');
                icon.style.color = ''; 
                if(wishCount > 0) wishCount--;
            }
            
            // Persist & Update
            localStorage.setItem('ecomm_wishlist_count', wishCount);
            updateHeaderCounters();
            // Pulse effect on header icon
            pulseHeaderIcon('wishlist-count');
            return;
        }

        // -- CASE: ADD TO CART CLICKED --
        let cartBtn = e.target.closest('.add-cart-btn');
        if (cartBtn) {
            e.preventDefault();
            
            // Loading feedback on button
            let originalHtml = cartBtn.innerHTML;
            cartBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding...';
            cartBtn.style.pointerEvents = 'none';
            
            setTimeout(() => {
                cartCount++;
                localStorage.setItem('ecomm_cart_count', cartCount);
                updateHeaderCounters();
                
                // Reset button state with checkmark feedback
                cartBtn.innerHTML = '<i class="fas fa-check"></i> Added';
                cartBtn.style.background = '#22c55e';
                cartBtn.style.color = '#fff';
                
                pulseHeaderIcon('cart-count');
                showFeedbackToast('Product added to cart successfully!');
                
                // Revert button back to default state after 1.5 seconds
                setTimeout(() => {
                    cartBtn.innerHTML = originalHtml;
                    cartBtn.style.background = '';
                    cartBtn.style.color = '';
                    cartBtn.style.pointerEvents = 'auto';
                }, 1500);
            }, 600);
        }
    });

    // UI Feedback Utilities
    function pulseHeaderIcon(elementId) {
        const el = document.getElementById(elementId);
        if(!el) return;
        el.classList.remove('pulse-animation');
        void el.offsetWidth; // trigger reflow
        el.classList.add('pulse-animation');
    }

    function showFeedbackToast(msg) {
        // Implement minimal simple toast dynamically
        let toast = document.createElement('div');
        toast.innerText = msg;
        toast.style.cssText = 'position:fixed; bottom: 20px; left: 50%; transform: translateX(-50%); background: #162032; color: #fff; padding: 12px 24px; border-radius: 8px; font-weight: 600; font-size:14px; z-index: 99999; box-shadow: 0 10px 25px rgba(0,0,0,0.2); transition: opacity 0.5s; opacity:0;';
        document.body.appendChild(toast);
        
        requestAnimationFrame(() => { toast.style.opacity = '1'; });
        
        setTimeout(() => {
            toast.style.opacity = '0';
            setTimeout(() => toast.remove(), 500);
        }, 2500);
    }
});


