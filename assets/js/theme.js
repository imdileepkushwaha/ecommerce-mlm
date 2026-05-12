/* ========================
   PRELOADER HIDE
   ======================== */
document.addEventListener('DOMContentLoaded', function() {
    const loader = document.getElementById('preloader');
    if (loader) {
        loader.classList.add('preloader-hidden');
    }
});
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
document.addEventListener('DOMContentLoaded', function() {
    // Safely load jQuery plugins only if defined to prevent script execution halts
    if (typeof jQuery !== 'undefined') {
        // 2. Testimonial Carousel
        var $tSlider = jQuery('.testimonial-slider-wrapper');
        if ($tSlider.length > 0 && typeof jQuery.fn.slick !== 'undefined' && !$tSlider.hasClass('slick-initialized')) {
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
    }
});


/* ========================
   ECOMMERCE STATE LOGIC (CART & WISHLIST)
   ======================== */

document.addEventListener('DOMContentLoaded', function() {
    // 1. Initialize state (Cart from database value, Wishlist from localStorage)
    const cartElOnLoad = document.getElementById('cart_count');
    const wishElOnLoad = document.getElementById('wishlist_count');
    let cartCount = cartElOnLoad ? parseInt(cartElOnLoad.innerText) || 0 : 0;
    let wishCount = wishElOnLoad ? parseInt(wishElOnLoad.innerText) || 0 : 0;

    // Function to sync UI with State
    function updateHeaderCounters() {
        const cartEl = document.getElementById('cart_count');
        const wishEl = document.getElementById('wishlist_count');
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
            let pid = wishBtn.getAttribute('data-pid');
            if (!pid) return;

            let icon = wishBtn.querySelector('i');
            let isAdding = icon.classList.contains('far');
            let actionStr = isAdding ? 'add' : 'remove';

            // Immediate optimistic UI response
            if (isAdding) {
                icon.classList.replace('far', 'fas');
                icon.style.color = '#f43f5e'; 
                wishCount++;
            } else {
                icon.classList.replace('fas', 'far');
                icon.style.color = ''; 
                if(wishCount > 0) wishCount--;
            }

            // Sync header immediately
            updateHeaderCounters();
            pulseHeaderIcon('wishlist_count');

            // Persist asynchronously
            fetch('AddToWishlist.ashx?action=' + actionStr + '&pid=' + pid)
                .then(r => r.json())
                .then(d => {
                    if(d.success) {
                         // Force exact count from server rather than speculative increment
                         if (typeof d.totalCount !== 'undefined') {
                             wishCount = d.totalCount;
                             updateHeaderCounters(); 
                         }
                         showFeedbackToast(isAdding ? 'Saved to wishlist!' : 'Removed from wishlist');
                    } else {
                         console.error('Wishlist sync failed', d.message);
                    }
                }).catch(err => console.error('Wishlist connection error', err));

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
            
            let pid = cartBtn.getAttribute('data-pid');
            if(!pid) {
                cartBtn.innerHTML = originalHtml;
                cartBtn.style.pointerEvents = 'auto';
                return;
            }

            fetch('AddToCart.ashx?pid=' + pid)
            .then(res => res.json())
            .then(data => {
                if(data.success) {
                    cartCount = data.totalCount; // Use real count from DB
                    localStorage.setItem('ecomm_cart_count', cartCount);
                    updateHeaderCounters();
                    
                    cartBtn.innerHTML = '<i class="fas fa-check"></i> Added';
                    cartBtn.style.background = '#22c55e';
                    cartBtn.style.color = '#fff';
                    
                    pulseHeaderIcon('cart_count');
                    showFeedbackToast('Product added to cart successfully!');
                } else {
                    cartBtn.innerHTML = 'Error';
                    showFeedbackToast('Failed to add item!');
                }
                
                setTimeout(() => {
                    cartBtn.innerHTML = originalHtml;
                    cartBtn.style.background = '';
                    cartBtn.style.color = '';
                    cartBtn.style.pointerEvents = 'auto';
                }, 1500);
            })
            .catch(err => {
                cartBtn.innerHTML = originalHtml;
                cartBtn.style.pointerEvents = 'auto';
                showFeedbackToast('Connection error occurred!');
            });
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




/* ========================================
   GLOBAL BUY NOW HANDLER
   ======================================== */
document.addEventListener('DOMContentLoaded', function() {
    document.body.addEventListener('click', function(e) {
        const buyBtn = e.target.closest('.js-buy-now');
        if (buyBtn) {
            e.preventDefault();
            let pid = buyBtn.getAttribute('data-pid');
            buyBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
            buyBtn.style.pointerEvents = 'none';

            fetch('AddToCart.ashx?pid=' + pid + '&qty=1')
                .then(r => r.json())
                .then(data => {
                    // Successful addition -> redirect to cart IMMEDIATELY
                    window.location.href = 'Cart.aspx';
                })
                .catch(err => {
                    if (typeof showToast !== 'undefined') showToast('Action failed.', 'error');
                    else alert('Action failed.');
                    buyBtn.innerHTML = 'Buy Now';
                    buyBtn.style.pointerEvents = 'auto';
                });
        }
    });
});

/* ========================================
   CART PAGE FUNCTIONALITY
   ======================================== */
document.addEventListener('DOMContentLoaded', function () {
    // Ensure we are only executing on cart context safely
    const isCartPage = document.querySelector('.cart-page-wrapper') !== null;
    if (!isCartPage) return;

    console.log('Cart Logic Initialized.');

    // HIGHLY DEFENSIVE CALCULATION ROUTINE
    function recalculateCartTotals() {
        try {
            let subtotal = 0;
            let itemCount = 0;

            // 1. Process Individual Cards Safely
            document.querySelectorAll('.cart-item-card').forEach(card => {
                const qtyInput = card.querySelector('.item-qty-val');
                const qtyRow = card.querySelector('.item-qty-row');
                const lineTotalEl = card.querySelector('.item-line-total');

                if (!qtyInput || !qtyRow) return; // skip iteration if critical DOM node is missing

                let qty = parseInt(qtyInput.value) || 0;
                let unitPrice = parseFloat(qtyRow.getAttribute('data-unitprice')) || 0;
                let lineTotal = qty * unitPrice;

                if (lineTotalEl) {
                    lineTotalEl.innerText = '₹ ' + lineTotal.toLocaleString('en-IN');
                }

                subtotal += lineTotal;
                itemCount += qty;
            });

            // 2. Update Master Counters
            const countEl = document.getElementById('js-count-span');
            if (countEl) countEl.innerText = itemCount;

            // Sync global header badge
            const headerCart = document.getElementById('cart_count');
            if (headerCart) headerCart.innerText = itemCount;

            const subValEl = document.getElementById('js-subtotal-val');
            if (subValEl) subValEl.innerText = subtotal.toLocaleString('en-IN');

            // 3. Free Delivery Dynamic Presentation
            const promoDesc = document.getElementById('js-promo-desc');
            const promoBanner = document.getElementById('divFreePromoBanner');
            const stdOption = document.querySelector('.js-speed-option[data-fee="25"]');
            let isEligible = subtotal >= 1000;

            if (isEligible) {
                if (promoDesc) promoDesc.innerHTML = '🎉 <span style="color:#047857">Awesome! Your shipping is FREE.</span>';
                if (promoBanner) promoBanner.classList.add('unlocked');
                if (stdOption) {
                    const costNode = stdOption.querySelector('.speed-cost');
                    if (costNode) costNode.innerText = 'FREE';
                }
            } else {
                let diff = 1000 - subtotal;
                if (promoDesc) promoDesc.innerHTML = 'Add <b>₹ ' + diff.toLocaleString('en-IN') + '</b> more for FREE Delivery!';
                if (promoBanner) promoBanner.classList.remove('unlocked');
                if (stdOption) {
                    const costNode = stdOption.querySelector('.speed-cost');
                    if (costNode) costNode.innerText = '₹ 25';
                }
            }

            // 4. Shipping Fee Computations
            const selectedSpeed = document.querySelector('.js-speed-option.selected');
            let baseFee = 25;
            if (selectedSpeed && selectedSpeed.hasAttribute('data-fee')) {
                baseFee = parseFloat(selectedSpeed.getAttribute('data-fee')) || 0;
            }

            let deliveryFee = baseFee;
            // Dynamic wave-off logic if threshold is met on standard option
            if (baseFee === 25 && isEligible) {
                deliveryFee = 0;
            }

            // 5. Total Breakdown updates with zero risk format access
            const delCell = document.getElementById('js-delivery-val');
            if (delCell) {
                if (deliveryFee === 0 && subtotal > 0) {
                    delCell.innerHTML = '<span style="color:#10b981; font-weight:800;">FREE</span>';
                } else {
                    delCell.innerHTML = '₹ ' + deliveryFee;
                }
            }

            // Safe retrieval of platform fee to avoid null string replace errors
            let platformFee = 0;
            const platformEl = document.getElementById('js-platform-val');
            if (platformEl && platformEl.innerText) {
                platformFee = parseFloat(platformEl.innerText.replace(/[^0-9.]/g, '')) || 0;
            }

            let finalTotal = subtotal > 0 ? (subtotal + deliveryFee + platformFee) : 0;

            const finalEl = document.getElementById('js-final-total');
            if (finalEl) finalEl.innerText = finalTotal.toLocaleString('en-IN');

            // 6. External Meta syncing
            const bcrCount = document.querySelector('.cart-breadcrumb-badge span');
            if (bcrCount) {
                bcrCount.innerText = document.querySelectorAll('.cart-item-card').length;
            }
        } catch (err) {
            console.error('Recalculation Error Intercepted:', err);
        }
    }

    // --------------------------------------------------
    // ROBUST GLOBAL EVENT DELEGATION FOR CART ACTIONS
    // --------------------------------------------------

    document.body.addEventListener('click', function (e) {
        // Check specific event targets using robust closest propagation
        
        // A. QUANTITY PLUS / MINUS HANDLER
        const qtyBtn = e.target.closest('.btn-qty-plus, .btn-qty-minus');
        if (qtyBtn) {
            e.preventDefault();
            const parentRow = qtyBtn.closest('.item-qty-row');
            if (!parentRow) return;

            const input = parentRow.querySelector('.item-qty-val');
            const cid = parentRow.getAttribute('data-cid');
            if (!input || !cid) return;

            let val = parseInt(input.value) || 1;
            if (qtyBtn.classList.contains('btn-qty-plus')) {
                val++;
            } else {
                if (val > 1) val--;
            }

            // Immediate Update
            input.value = val;
            recalculateCartTotals();

            // Server Sync
            fetch('UpdateCart.ashx?action=update&cid=' + cid + '&qty=' + val)
                .then(r => r.json())
                .then(d => {
                    if (!d.success) { 
                        showToast(d.error || 'Sync failed', 'error', 'Connection error'); 
                    }
                }).catch(err => console.error('Sync failure', err));
            return;
        }

        // B. SPEED OPTION TOGGLE HANDLER
        const speedOpt = e.target.closest('.js-speed-option');
        if (speedOpt) {
            e.preventDefault();
            document.querySelectorAll('.js-speed-option').forEach(o => o.classList.remove('selected'));
            speedOpt.classList.add('selected');
            recalculateCartTotals();
            return;
        }

        // C. REMOVE OR SAVE ITEM HANDLERS
        const removeBtn = e.target.closest('.btn-item-remove');
        const saveBtn = e.target.closest('.btn-save-later');
        
        if (removeBtn) {
            e.preventDefault();
            if (confirm('Are you sure you want to remove this item?')) {
                processItemRemoval(removeBtn, 'delete');
            }
            return;
        }
        if (saveBtn) {
            e.preventDefault();
            processItemRemoval(saveBtn, 'save');
            return;
        }

        // D. BULK ACTIONS HANDLER
        const bulkBtn = e.target.closest('#btnSaveAll, #btnRemoveAll');
        if (bulkBtn) {
            e.preventDefault();
            const isSaveAction = bulkBtn.id === 'btnSaveAll';
            const promptMsg = isSaveAction ? 'Move all items to Saved for Later?' : 'Clear ALL cart items?';
            const actionParam = isSaveAction ? 'save' : 'delete';

            if (confirm(promptMsg)) {
                fetch('UpdateCart.ashx?action=' + actionParam + '&cid=all')
                    .then(r => r.json()).then(data => {
                        if (data.success) window.location.reload();
                    }).catch(err => console.error('Bulk action failure', err));
            }
            return;
        }

        // E. MOVE TO CART HANDLER (FROM SAVED SECTION)
        const moveBtn = e.target.closest('.btn-move-to-cart');
        if (moveBtn) {
            e.preventDefault();
            const cid = moveBtn.getAttribute('data-cid');
            if (!cid) return;
            fetch('UpdateCart.ashx?action=movetocart&cid=' + cid)
                .then(r => r.json()).then(data => {
                    if (data.success) window.location.reload();
                    else showToast('Failed to move item.', 'error');
                }).catch(err => console.error('Move action failure', err));
            return;
        }
    });

    // INDIVIDUAL CHANGE EVENT DELEGATION
    document.body.addEventListener('change', function (e) {
        // 1. SELECT ALL HANDLER
        if (e.target && e.target.id === 'chkSelectAll') {
            const itemChecks = document.querySelectorAll('.item-chk');
            itemChecks.forEach(chk => chk.checked = e.target.checked);
        }
    });

    // CORE DOM MODIFICATION WORKER
    function processItemRemoval(buttonEl, type) {
        try {
            const cid = buttonEl.getAttribute('data-cid');
            if (!cid) return;

            const card = buttonEl.closest('.cart-item-card') || buttonEl.closest('.saved-card');
            const isSavedArea = buttonEl.closest('.saved-card') !== null;
            if (!card) return;

            card.style.opacity = '0.5';
            card.style.pointerEvents = 'none';

            const actionStr = (type === 'save') ? 'save' : 'delete';
            fetch('UpdateCart.ashx?action=' + actionStr + '&cid=' + cid)
                .then(r => r.json())
                .then(data => {
                    if (data.success) {
                        card.style.transform = 'translateX(100px)';
                        card.style.opacity = '0';
                        setTimeout(() => {
                            card.remove();
                            if (isSavedArea) {
                                window.location.reload();
                                return;
                            }
                            recalculateCartTotals();

                            if (type === 'save') {
                                // Simulating count update purely for state visual loop
                                let wCount = parseInt(localStorage.getItem('ecomm_wishlist_count')) || 0;
                                wCount++;
                                localStorage.setItem('ecomm_wishlist_count', wCount);
                                const wEl = document.getElementById('wishlist_count');
                                if (wEl) { wEl.innerText = wCount; wEl.classList.add('pulse'); }

                                showToast('Item saved for later!', 'success');
                                window.location.reload(); // Refetch full structure 
                            }

                            
                            // check for actual empty state to trigger reload
                            if (document.querySelectorAll('.cart-item-card').length === 0) {
                                window.location.reload();
                            }
                        }, 300);
                    } else {
                        card.style.opacity = '1';
                        card.style.pointerEvents = 'auto';
                        showToast('Operation failed.', 'error');
                    }
                })
                .catch(err => {
                    card.style.opacity = '1';
                    card.style.pointerEvents = 'auto';
                    showToast('Network error.', 'error');
                });
        } catch (err) {
            console.error('Critical Removal Routine Crash:', err);
        }
    }
});
