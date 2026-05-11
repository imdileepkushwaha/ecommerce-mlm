<%@ Page Title="Home" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true" CodeFile="index.aspx.cs"
    Inherits="ecommerce_mlm.index" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <!-- Additional head content for index page can go here -->
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <!-- HERO SECTION -->
        <section class="kartify-hero" id="homeHero">
            <div class="hero-slider-window">
                <div class="hero-slides-track" id="heroTrack">

                    <!-- Slide 1 -->
                    <div class="hero-slide">
                        <div class="container hero-inner">
                            <div class="hero-content">
                                <span class="hero-subtitle">Best for your categories</span>
                                <h1 class="hero-title">
                                    Exclusive Collection <br />
                                    in <span class="highlight-pill">Our Online</span> Store
                                </h1>
                                <p class="hero-desc">
                                    Discover our exclusive collection available only in our online store. Shop now for
                                    unique and premium items that you won't find anywhere else.
                                </p>
                                <a href="#" class="btn btn-dark-pill">Shop Now</a>
                            </div>
                            <div class="hero-image-area">
                                <div class="hero-image-wrapper">
                                    <img src="assets/images/banner/banner-1.jpg" alt="Fashion Model" class="hero-img" />
                                    <div class="hero-img-border"></div>
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
                                    Discover the <br />
                                    <span class="highlight-pill" style="background-color: #a7f3d0;">Latest Trends</span>
                                    Here
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
                                    Get Up To <br />
                                    <span class="highlight-pill" style="background-color: #fca5a5;">50% Off</span> Today
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
        <div class="scrolling-ticker">
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
        </div>

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
                    <div class="category-arrows">
                        <button class="cat-arrow prev-cat" type="button"><i class="fa fa-arrow-left"></i></button>
                        <button class="cat-arrow next-cat" type="button"><i class="fa fa-arrow-right"></i></button>
                    </div>
                </div>

                <div class="category-slider-wrapper">
                    <div class="category-slider-track" id="categorySliderTrack">
                        <!-- Item 1 -->
                        <div class="category-item-container">
                            <div class="category-item">
                                <img src="https://placehold.co/400x400/eeeeee/333333?text=Shirts" alt="Man Shirts" />
                                <div class="category-label">Man Shirts</div>
                            </div>
                        </div>
                        <div class="category-divider"></div>

                        <!-- Item 2 -->
                        <div class="category-item-container">
                            <div class="category-item">
                                <img src="https://placehold.co/400x400/eeeeee/333333?text=Jeans" alt="Denim Jeans" />
                                <div class="category-label">Denim Jeans</div>
                            </div>
                        </div>
                        <div class="category-divider"></div>

                        <!-- Item 3 -->
                        <div class="category-item-container">
                            <div class="category-item">
                                <img src="https://placehold.co/400x400/eeeeee/333333?text=Suit" alt="Casual Suit" />
                                <div class="category-label">Casual Suit</div>
                            </div>
                        </div>
                        <div class="category-divider"></div>

                        <!-- Item 4 -->
                        <div class="category-item-container">
                            <div class="category-item">
                                <img src="https://placehold.co/400x400/eeeeee/333333?text=Dress" alt="Summer Dress" />
                                <div class="category-label">Summer Dress</div>
                            </div>
                        </div>
                        <div class="category-divider"></div>

                        <!-- Item 5 -->
                        <div class="category-item-container">
                            <div class="category-item">
                                <img src="https://placehold.co/400x400/eeeeee/333333?text=Sweaters" alt="Sweaters" />
                                <div class="category-label">Sweaters</div>
                            </div>
                        </div>
                        <div class="category-divider"></div>

                        <!-- Item 6 -->
                        <div class="category-item-container">
                            <div class="category-item">
                                <img src="https://placehold.co/400x400/eeeeee/333333?text=Jackets" alt="Jackets" />
                                <div class="category-label">Jackets</div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </section>

        <!-- FEATURED PRODUCTS -->
        <section class="products-section">
            <div class="container">
                <h2 class="section-title">Featured Products</h2>
                <div class="product-grid">
                    <!-- Product Card 1 -->
                    <div class="product-card">
                        <div class="product-img">
                            <img src="https://via.placeholder.com/250x250?text=Product+1" alt="Product 1" />
                        </div>
                        <div class="product-info">
                            <h3>Awesome T-Shirt</h3>
                            <p class="price">$25.00</p>
                            <a href="#" class="btn btn-outline">Add to Cart</a>
                        </div>
                    </div>

                    <!-- Product Card 2 -->
                    <div class="product-card">
                        <div class="product-img">
                            <img src="https://via.placeholder.com/250x250?text=Product+2" alt="Product 2" />
                        </div>
                        <div class="product-info">
                            <h3>Sneakers</h3>
                            <p class="price">$55.00</p>
                            <a href="#" class="btn btn-outline">Add to Cart</a>
                        </div>
                    </div>

                    <!-- Product Card 3 -->
                    <div class="product-card">
                        <div class="product-img">
                            <img src="https://via.placeholder.com/250x250?text=Product+3" alt="Product 3" />
                        </div>
                        <div class="product-info">
                            <h3>Smart Watch</h3>
                            <p class="price">$120.00</p>
                            <a href="#" class="btn btn-outline">Add to Cart</a>
                        </div>
                    </div>

                    <!-- Product Card 4 -->
                    <div class="product-card">
                        <div class="product-img">
                            <img src="https://via.placeholder.com/250x250?text=Product+4" alt="Product 4" />
                        </div>
                        <div class="product-info">
                            <h3>Wireless Headphones</h3>
                            <p class="price">$80.00</p>
                            <a href="#" class="btn btn-outline">Add to Cart</a>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </asp:Content>