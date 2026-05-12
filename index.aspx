<%@ Page Title="Home" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true" CodeFile="index.aspx.cs"
    Inherits="ecommerce_mlm.index" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <!-- Slick Slider CSS CDN for Testimonial -->
        <link rel="stylesheet" type="text/css"
            href="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css" />
        <link rel="stylesheet" type="text/css"
            href="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css" />
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <!-- HERO SECTION -->
        <section class="kartify-hero" id="homeHero">
            <!-- Dynamic Background Shapes -->
            <div class="hero-bg-element element-1"></div>
            <div class="hero-bg-element element-2"></div>
            <div class="hero-bg-element element-3"></div>
            <!-- Floating Shopping Emojis Background -->
            <div class="floating-emoji emoji-1">🛍️</div>
            <div class="floating-emoji emoji-2">👠</div>
            <div class="floating-emoji emoji-3">👜</div>
            <div class="floating-emoji emoji-4">👟</div>
            <div class="floating-emoji emoji-5">🎁</div>
            <div class="floating-emoji emoji-6">🔥</div>

            <div class="hero-slider-window">
                <div class="hero-slides-track" id="heroTrack">

                    <!-- Slide 1 -->
                    <div class="hero-slide">
                        <div class="container hero-inner">
                            <div class="hero-content">
                                <span class="hero-subtitle">Best for your categories</span>
                                <h1 class="hero-title">
                                    <span class="text-gradient">Exclusive</span> Collection <br />
                                    in <span class="highlight-pill">Our Online</span> Store
                                </h1>
                                <p class="hero-desc">
                                    Discover our exclusive collection available only in our online store. Shop now for
                                    unique and premium items that you won't find anywhere else.
                                </p>
                                <a href="#" class="btn btn-dark-pill">Shop Now <i class="fas fa-arrow-right"
                                        style="margin-left:8px; font-size:12px;"></i></a>
                            </div>
                            <div class="hero-image-area">
                                <div class="hero-image-wrapper">
                                    <img src="assets/images/banner/banner-1.jpg" alt="Fashion Model" class="hero-img" />
                                    <div class="hero-img-border"></div>
                                    <!-- Floating Information Badges -->
                                    <div class="floating-hero-badge badge-top bounce-effect">
                                        <div class="icon"><i class="fas fa-heart"></i></div>
                                        <div class="text">
                                            <strong>2k+</strong>
                                            <span>Favorites</span>
                                        </div>
                                    </div>
                                    <div class="floating-hero-badge badge-bottom pulse-slow">
                                        <div class="icon star"><i class="fas fa-star"></i></div>
                                        <div class="text">
                                            <strong>4.9/5</strong>
                                            <span>(1.5k Reviews)</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Slide 2 -->
                    <div class="hero-slide">
                        <div class="container hero-inner">
                            <div class="hero-content">
                                <span class="hero-subtitle">New Arrivals</span>
                                <h1 class="hero-title">
                                    <span class="text-gradient">Discover</span> the <br />
                                    <span class="highlight-pill pill-mint">Latest Trends</span> Here
                                </h1>
                                <p class="hero-desc">
                                    Step into the new season with our latest arrivals. Elevate your wardrobe with fresh
                                    styles and vibrant colors.
                                </p>
                                <a href="#" class="btn btn-dark-pill">Explore Now</a>
                            </div>
                            <div class="hero-image-area">
                                <div class="hero-image-wrapper">
                                    <img src="assets/images/banner/banner-2.jpg" alt="Fashion Model 2"
                                        class="hero-img" />
                                    <div class="hero-img-border"></div>
                                    <!-- Floating Information Badges for Slide 2 -->
                                    <div class="floating-hero-badge badge-top bounce-effect">
                                        <div class="icon"><i class="fas fa-heart"></i></div>
                                        <div class="text">
                                            <strong>2k+</strong>
                                            <span>Favorites</span>
                                        </div>
                                    </div>
                                    <div class="floating-hero-badge badge-bottom pulse-slow">
                                        <div class="icon star"><i class="fas fa-star"></i></div>
                                        <div class="text">
                                            <strong>4.9/5</strong>
                                            <span>(1.5k Reviews)</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Slide 3 -->
                    <div class="hero-slide">
                        <div class="container hero-inner">
                            <div class="hero-content">
                                <span class="hero-subtitle">Special Offers</span>
                                <h1 class="hero-title">
                                    <span class="text-gradient">Get Up</span> To <br />
                                    <span class="highlight-pill pill-coral">50% Off</span> Today
                                </h1>
                                <p class="hero-desc">
                                    Don't miss out on our limited-time special offers. Grab your favorite items at half
                                    the price before they run out!
                                </p>
                                <a href="#" class="btn btn-dark-pill">Grab Offer</a>
                            </div>
                            <div class="hero-image-area">
                                <div class="hero-image-wrapper">
                                    <img src="assets/images/banner/banner-3.jpg" alt="Fashion Model 3"
                                        class="hero-img" />
                                    <div class="hero-img-border"></div>
                                    <!-- Floating Information Badges for Slide 3 -->
                                    <div class="floating-hero-badge badge-top bounce-effect">
                                        <div class="icon"><i class="fas fa-heart"></i></div>
                                        <div class="text">
                                            <strong>2k+</strong>
                                            <span>Favorites</span>
                                        </div>
                                    </div>
                                    <div class="floating-hero-badge badge-bottom pulse-slow">
                                        <div class="icon star"><i class="fas fa-star"></i></div>
                                        <div class="text">
                                            <strong>4.9/5</strong>
                                            <span>(1.5k Reviews)</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>

            <!-- Carousel dots -->
            <div class="hero-dots">
                <span class="dot active" onclick="changeSlide(0)"></span>
                <span class="dot" onclick="changeSlide(1)"></span>
                <span class="dot" onclick="changeSlide(2)"></span>
            </div>
        </section>

        <!-- SCROLLING TICKER -->
        <section class="scrolling-ticker">
            <div class="ticker-track">
                <!-- Repeat items to create an infinite scroll effect -->
                <div class="ticker-item"><i class="fas fa-bahai"></i> <span>JACKETS</span></div>
                <div class="ticker-item"><i class="fas fa-bahai"></i> <span>JEANS</span></div>
                <div class="ticker-item"><i class="fas fa-bahai"></i> <span>BLAZER</span></div>
                <div class="ticker-item"><i class="fas fa-bahai"></i> <span>MEN</span></div>
                <div class="ticker-item"><i class="fas fa-bahai"></i> <span>WOMEN</span></div>
                <div class="ticker-item"><i class="fas fa-bahai"></i> <span>SNEAKERS</span></div>
                <!-- Duplicate for seamless loop -->
                <div class="ticker-item"><i class="fas fa-bahai"></i> <span>JACKETS</span></div>
                <div class="ticker-item"><i class="fas fa-bahai"></i> <span>JEANS</span></div>
                <div class="ticker-item"><i class="fas fa-bahai"></i> <span>BLAZER</span></div>
                <div class="ticker-item"><i class="fas fa-bahai"></i> <span>MEN</span></div>
                <div class="ticker-item"><i class="fas fa-bahai"></i> <span>WOMEN</span></div>
                <div class="ticker-item"><i class="fas fa-bahai"></i> <span>SNEAKERS</span></div>
            </div>
        </section>

        <!-- FEATURES SECTION -->
        <section class="features-section">
            <div class="container">
                <div class="features-box">
                    <!-- Feature 1 -->
                    <div class="feature-item">
                        <div class="feature-icon">
                            <i class="fas fa-shipping-fast"></i>
                        </div>
                        <div class="feature-text">
                            <h4>Free Shipping</h4>
                            <p>You get your items delivered without any extra cost.</p>
                        </div>
                    </div>

                    <div class="feature-divider"></div>

                    <!-- Feature 2 -->
                    <div class="feature-item">
                        <div class="feature-icon">
                            <i class="fas fa-microphone-alt"></i>
                        </div>
                        <div class="feature-text">
                            <h4>Great Support 24/7</h4>
                            <p>Our customer support team is available around the clock.</p>
                        </div>
                    </div>

                    <div class="feature-divider"></div>

                    <!-- Feature 3 -->
                    <div class="feature-item">
                        <div class="feature-icon">
                            <i class="fas fa-handshake"></i>
                        </div>
                        <div class="feature-text">
                            <h4>Return Available</h4>
                            <p>Making it easy to return any items if you're not satisfied.</p>
                        </div>
                    </div>

                    <div class="feature-divider"></div>

                    <!-- Feature 4 -->
                    <div class="feature-item">
                        <div class="feature-icon">
                            <i class="fas fa-sack-dollar"></i>
                        </div>
                        <div class="feature-text">
                            <h4>Secure Payment</h4>
                            <p>Shop with confidence knowing that our secure payment.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- TOP CATEGORIES SLIDER -->
        <section class="top-categories-section">
            <div class="container">
                <div class="category-header">
                    <div class="category-title-area">
                        <div class="category-subtitle">
                            <i class="fas fa-crosshairs"></i> Categories
                        </div>
                        <h2 class="category-main-title">Browse Top Category</h2>
                    </div>

                </div>

                <div class="category-slider-wrapper">
                    <div class="category-slider-track">
                        <!-- Item 1 -->
                        <div class="category-item-container">
                            <div class="category-item">
                                <h2>Shirts</h2>
                                <div class="category-label">Man Shirts</div>
                            </div>
                        </div>
                        <div class="category-divider"></div>

                        <!-- Item 2 -->
                        <div class="category-item-container">
                            <div class="category-item">
                                <h2>Jeans</h2>
                                <div class="category-label">Denim Jeans</div>
                            </div>
                        </div>
                        <div class="category-divider"></div>

                        <!-- Item 3 -->
                        <div class="category-item-container">
                            <div class="category-item">
                                <h2>Suit</h2>
                                <div class="category-label">Casual Suit</div>
                            </div>
                        </div>
                        <div class="category-divider"></div>

                        <!-- Item 4 -->
                        <div class="category-item-container">
                            <div class="category-item">
                                <h2>Dress</h2>
                                <div class="category-label">Summer Dress</div>
                            </div>
                        </div>
                        <div class="category-divider"></div>

                        <!-- Item 5 -->
                        <div class="category-item-container">
                            <div class="category-item">
                                <h2>Sweaters</h2>
                                <div class="category-label">Sweaters</div>
                            </div>
                        </div>
                        <div class="category-divider"></div>

                        <!-- Item 6 -->
                        <div class="category-item-container">
                            <div class="category-item">
                                <h2>Jackets</h2>
                                <div class="category-label">Jackets</div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </section>

        <section class="banner-section">
            <div class="container">

                <div class="banner-section-inner">
                    <!--=== Banner Item ===-->
                    <div class="banner-item style-one bg-one">
                        <div class="shape shape-one"><span><img src="assets/images/banner/discount.png"
                                    alt="shape"></span>
                        </div>
                        <div class="shape shape-two"><span><img src="assets/images/banner/line.png" alt="shape"></span>
                        </div>
                        <div class="banner-img"><img src="assets/images/banner/banner-1.png" alt="banner image">
                        </div>
                        <div class="banner-content">
                            <span>UP TO <span class="off">50%</span></span>
                            <h4>Exclusive Kids &amp; Adults Summer Outfits</h4>
                            <a href="shops.html" class="theme-btn style-one">Shop Now</a>
                        </div>
                    </div>

                    <!--=== Banner Item ===-->
                    <div class="banner-item style-one bg-two">
                        <div class="shape shape-one"><span><img src="assets/images/banner/discount.png"
                                    alt="shape"></span>
                        </div>
                        <div class="shape shape-two"><span><img src="assets/images/banner/line.png" alt="shape"></span>
                        </div>
                        <div class="banner-img"><img src="assets/images/banner/banner-2.png" alt="banner image">
                        </div>
                        <div class="banner-content">
                            <span>UP TO <span class="off">70%</span></span>
                            <h4>Exclusive Kids &amp; Adults Summer Outfits</h4>
                            <a href="shops.html" class="theme-btn style-one">Shop Now</a>
                        </div>
                    </div>
                </div>

            </div>
            </div>
        </section>

        <!-- FEATURED PRODUCTS -->
        <section class="products-section">
            <div class="container">
                <div class="category-header mb-30">
                    <div class="category-title-area">
                        <div class="category-subtitle">
                            <i class="fas fa-bolt"></i> Trendy Now
                        </div>
                        <h2 class="category-main-title">Featured Products</h2>
                    </div>
                    <a href="ProductList.aspx" class="btn-view-all">View All <i class="fas fa-arrow-right"></i></a>
                </div>
                <div class="product-grid">
                    <asp:Repeater ID="rptFeaturedProducts" runat="server">
                        <ItemTemplate>
                            <div class="product-card">
                                <div class="product-card-img">
                                    <span class="product-badge" runat="server"
                                        visible='<%# Eval("BadgeText") != DBNull.Value && !string.IsNullOrEmpty(Eval("BadgeText").ToString()) %>'>
                                        <%# Eval("BadgeText") %>
                                    </span>
                                    <span class="discount-tag">
                                        <%# GetDiscountPercentage(Eval("Price"), Eval("Mrp")) %>
                                    </span>
                                    <img src='<%# ResolveUrl(Eval("MainImage") != DBNull.Value && Eval("MainImage").ToString() != "" ? Eval("MainImage").ToString() : "https://via.placeholder.com/300?text=No+Image") %>'
                                        alt='<%# Eval("Name") %>' />

                                    <div class="product-actions">
                                        <a href="#" class="action-btn" title="Add to Wishlist"
                                            data-pid='<%# Eval("Id") %>'><i class="far fa-heart"></i></a>
                                        <a href='<%# "ProductDetails.aspx?slug=" + Eval("Slug") %>' class="action-btn"
                                            title="Quick View"><i class="far fa-eye"></i></a>
                                    </div>
                                </div>
                                <div class="product-card-body">
                                    <div class="prod-rating">
                                        <i class="fas fa-star"></i><i class="fas fa-star"></i><i
                                            class="fas fa-star"></i><i class="fas fa-star"></i><i
                                            class="fas fa-star-half-alt"></i>
                                        <span>(4.5)</span>
                                    </div>
                                    <span class="prod-brand">
                                        <%# Eval("Brand") %>
                                    </span>
                                    <h3><a href='<%# "ProductDetails.aspx?slug=" + Eval("Slug") %>'>
                                            <%# Eval("Name") %>
                                        </a></h3>
                                    <div class="prod-pricing">
                                        <span class="current-price">₹ <%#
                                                Convert.ToDecimal(Eval("Price")).ToString("N2") %></span>
                                        <span class="old-price">₹ <%# Convert.ToDecimal(Eval("Mrp")).ToString("N2") %>
                                        </span>
                                    </div>
                                    <div class="prod-action-row">
                                        <a href="javascript:void(0);" class="add-cart-btn" data-pid='<%# Eval("Id") %>'
                                            title="Add to Cart"><i class="fas fa-shopping-basket"></i></a>
                                        <a href="javascript:void(0);" class="buy-now-btn js-buy-now"
                                            data-pid='<%# Eval("Id") %>'>Buy Now</a>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </section>

        <!-- HOW IT WORKS SECTION -->
        <section class="process-section">
            <div class="container">
                <div class="category-header mb-30 text-center" style="justify-content: center;">
                    <div class="category-title-area text-center"
                        style="align-items: center; display: flex; flex-direction: column;">
                        <div class="category-subtitle">
                            <i class="fas fa-cogs"></i> Easy Steps
                        </div>
                        <h2 class="category-main-title">How it Works</h2>
                    </div>
                </div>

                <div class="process-container">
                    <!-- Step 1 -->
                    <div class="process-step">
                        <div class="process-icon-circle">
                            <span class="process-step-num">01</span>
                            <i class="fas fa-search"></i>
                        </div>
                        <h4>Browsing & Choosing</h4>
                        <p>Explore vast collections and pick the products tailored for you.</p>
                        <div class="process-connector"></div>
                    </div>

                    <!-- Step 2 -->
                    <div class="process-step">
                        <div class="process-icon-circle">
                            <span class="process-step-num">02</span>
                            <i class="fas fa-wallet"></i>
                        </div>
                        <h4>Checkout & Payment</h4>
                        <p>Safely enter payment details with complete transaction security.</p>
                        <div class="process-connector"></div>
                    </div>

                    <!-- Step 3 -->
                    <div class="process-step">
                        <div class="process-icon-circle">
                            <span class="process-step-num">03</span>
                            <i class="fas fa-box-open"></i>
                        </div>
                        <h4>Order Fulfillment</h4>
                        <p>We pack items with absolute care and strict quality control check.</p>
                        <div class="process-connector"></div>
                    </div>

                    <!-- Step 4 -->
                    <div class="process-step">
                        <div class="process-icon-circle">
                            <span class="process-step-num">04</span>
                            <i class="fas fa-shipping-fast"></i>
                        </div>
                        <h4>Delivery to Customer</h4>
                        <p>Sit back while your package arrives at speed right at your doorstep.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- WHAT'S TRENDING SECTION -->
        <section class="trending-section">
            <div class="container">
                <div class="category-header mb-30">
                    <div class="category-title-area">
                        <div class="category-subtitle">
                            <i class="fas fa-fire"></i> Must Haves
                        </div>
                        <h2 class="category-main-title">What's Trending Now</h2>
                    </div>
                </div>

                <div class="trending-grid">
                    <!-- Card 1: Women -->
                    <div class="trend-card">
                        <img src="assets/images/banner/trending-women.png" alt="Women" />
                        <div class="trend-overlay">
                            <span class="trend-tag">Popular</span>
                            <h3>Women's</h3>
                            <a href="#" class="trend-link">Shop Now <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>

                    <!-- Card 2: Men -->
                    <div class="trend-card">
                        <img src="assets/images/banner/trending-men.png" alt="Men" />
                        <div class="trend-overlay">
                            <span class="trend-tag">New</span>
                            <h3>Men's</h3>
                            <a href="#" class="trend-link">Shop Now <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>

                    <!-- Card 3: Kids -->
                    <div class="trend-card">
                        <img src="assets/images/banner/trending-kids.png" alt="Kids" />
                        <div class="trend-overlay">
                            <span class="trend-tag">Cute</span>
                            <h3>Kid's Wear</h3>
                            <a href="#" class="trend-link">Shop Now <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>

                    <!-- Card 4: Footwear -->
                    <div class="trend-card">
                        <img src="assets/images/banner/trending-foot.png" alt="Footwear" />
                        <div class="trend-overlay">
                            <span class="trend-tag">Trendy</span>
                            <h3>Footwear</h3>
                            <a href="#" class="trend-link">Shop Now <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>

                    <!-- Card 5: Accessories -->
                    <div class="trend-card">
                        <img src="assets/images/banner/trending-acc.png" alt="Acc" />
                        <div class="trend-overlay">
                            <span class="trend-tag">Luxe</span>
                            <h3>Accessories</h3>
                            <a href="#" class="trend-link">Shop Now <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- BEST DEAL SECTION -->
        <section class="best-deal-section">
            <div class="container">
                <div class="deal-wrapper">
                    <div class="deal-content">
                        <div class="deal-tag">
                            <i class="fas fa-clock"></i> Limited Edition Flash Sale
                        </div>
                        <h2>Summer Hot Deals of the Week</h2>
                        <p>Shop the curated premium fashion collection with incredible price drops. Only for selected
                            few. Grab them before stock expires!</p>

                        <!-- Countdown -->
                        <div class="countdown-timer">
                            <div class="timer-box">
                                <span id="deal-days">00</span>
                                <small>Days</small>
                            </div>
                            <div class="timer-box">
                                <span id="deal-hours">00</span>
                                <small>Hrs</small>
                            </div>
                            <div class="timer-box">
                                <span id="deal-mins">00</span>
                                <small>Mins</small>
                            </div>
                            <div class="timer-box">
                                <span id="deal-secs">00</span>
                                <small>Secs</small>
                            </div>
                        </div>

                        <a href="#" class="deal-btn">Shop Now <i class="fas fa-arrow-right"></i></a>
                    </div>
                    <div class="deal-image">
                        <img src="assets/images/banner/deal-promo.png" alt="High Premium Offer Image" />
                    </div>
                </div>
            </div>
        </section>



        <!-- TESTIMONIAL SECTION -->
        <section class="testimonial-section">
            <div class="container">
                <div class="category-header mb-30">
                    <div class="category-title-area">
                        <div class="category-subtitle">
                            <i class="fas fa-quote-left"></i> Feedbacks
                        </div>
                        <h2 class="category-main-title">Happy Clients Say</h2>
                    </div>
                </div>
                <div class="testimonial-slider-wrapper">
                    <!-- Testimonial 1 -->
                    <div class="testimonial-item">
                        <div class="testimonial-card">
                            <div class="testi-header">
                                <img src="https://randomuser.me/api/portraits/women/44.jpg" alt="User"
                                    class="testi-img" />
                                <div class="testi-user-title">
                                    <h4>Emily Johnson</h4>
                                    <p>Verified Buyer</p>
                                </div>
                                <i class="fas fa-quote-right testi-quote-icon"></i>
                            </div>
                            <div class="testi-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i
                                    class="fas fa-star"></i><i class="fas fa-star"></i>
                            </div>
                            <p class="testimonial-text">
                                "I ordered a jacket last week and it arrived today. The fabric quality is outstanding
                                and fitting is exactly as shown in size guide. Very satisfied with the overall service!"
                            </p>
                        </div>
                    </div>

                    <!-- Testimonial 2 -->
                    <div class="testimonial-item">
                        <div class="testimonial-card">
                            <div class="testi-header">
                                <img src="https://randomuser.me/api/portraits/men/32.jpg" alt="User"
                                    class="testi-img" />
                                <div class="testi-user-title">
                                    <h4>Michael Brown</h4>
                                    <p>Frequent Customer</p>
                                </div>
                                <i class="fas fa-quote-right testi-quote-icon"></i>
                            </div>
                            <div class="testi-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i
                                    class="fas fa-star"></i><i class="fas fa-star-half-alt"></i>
                            </div>
                            <p class="testimonial-text">
                                "One of the easiest navigation systems and checkout experiences I've used. Their
                                tracking system is real-time and payment security gives full peace of mind. Great work!"
                            </p>
                        </div>
                    </div>

                    <!-- Testimonial 3 -->
                    <div class="testimonial-item">
                        <div class="testimonial-card">
                            <div class="testi-header">
                                <img src="https://randomuser.me/api/portraits/women/68.jpg" alt="User"
                                    class="testi-img" />
                                <div class="testi-user-title">
                                    <h4>Sarah Parker</h4>
                                    <p>Fashion Enthusiast</p>
                                </div>
                                <i class="fas fa-quote-right testi-quote-icon"></i>
                            </div>
                            <div class="testi-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i
                                    class="fas fa-star"></i><i class="fas fa-star"></i>
                            </div>
                            <p class="testimonial-text">
                                "Excellent quality products and super fast delivery across different states. The
                                customer care responsive team saved my anniversary gift by prioritizing delivery. Highly
                                recommend!"
                            </p>
                        </div>
                    </div>

                    <!-- Testimonial 4 -->
                    <div class="testimonial-item">
                        <div class="testimonial-card">
                            <div class="testi-header">
                                <img src="https://randomuser.me/api/portraits/men/45.jpg" alt="User"
                                    class="testi-img" />
                                <div class="testi-user-title">
                                    <h4>David Wilson</h4>
                                    <p>Executive Client</p>
                                </div>
                                <i class="fas fa-quote-right testi-quote-icon"></i>
                            </div>
                            <div class="testi-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i
                                    class="fas fa-star"></i><i class="fas fa-star"></i>
                            </div>
                            <p class="testimonial-text">
                                "Amazing discounts on top tier premium brands. Bought formal wear recently and stitch
                                finishing is high class level. This has quickly become my favorite online marketplace."
                            </p>
                        </div>
                    </div>

                    <!-- Testimonial 5 -->
                    <div class="testimonial-item">
                        <div class="testimonial-card">
                            <div class="testi-header">
                                <img src="https://randomuser.me/api/portraits/women/22.jpg" alt="User"
                                    class="testi-img" />
                                <div class="testi-user-title">
                                    <h4>Jessica Lee</h4>
                                    <p>Regular Shopper</p>
                                </div>
                                <i class="fas fa-quote-right testi-quote-icon"></i>
                            </div>
                            <div class="testi-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i
                                    class="fas fa-star"></i><i class="fas fa-star"></i>
                            </div>
                            <p class="testimonial-text">
                                "I really appreciate their eco-friendly packaging materials and the zero hassle Easy
                                Return policy. It's incredibly trustworthy to shop here for all family requirements."
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- NEWSLETTER SUBSCRIPTION -->
        <section class="newsletter-section">
            <div class="container">
                <div class="newsletter-inner">
                    <img src="assets/images/newsletter/1.svg" class="newsletter-1 loaded" alt="">
                    <img src="assets/images/newsletter/2.svg" class="newsletter-2 loaded" alt="">
                    <img src="assets/images/newsletter/3.svg" class="newsletter-3 loaded" alt="">
                    <div class="news-left">
                        <div class="icon-box">
                            <i class="far fa-envelope-open"></i>
                        </div>
                        <div class="news-text">
                            <h3>Subscribe to our newsletter</h3>
                            <p>Get all the latest information on Events, sales and Offers</p>
                        </div>
                    </div>
                    <div class="news-right">
                        <div class="sub-form">
                            <input type="email" class="sub-input" placeholder="Enter Your E-mail Address" />
                            <button type="button" class="sub-btn">SUBSCRIBE NOW!</button>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Slick JS & Initializer Scripts -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script type="text/javascript"
            src="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>



    </asp:Content>