<%@ Page Title="User Dashboard" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true"
    CodeFile="userdashboard.aspx.cs" Inherits="ecommerce_mlm.userdashboard" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            /* Inline styles specific to Dashboard if not merging all, but I'll merge most in style.css. 
           Actually I'll place minimal here and major in CSS file as standard practice */
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <section class="dashboard-wrapper">

            <!-- Breadcrumb Top Bar -->
            <div class="dashboard-breadcrumb">
                <div class="container">
                    <div class="dashboard-breadcrumb-inner">
                        <div class="breadcrumb-left">
                            <h3>User Dashboard</h3>
                        </div>
                        <div class="breadcrumb-right">
                            <a href="index.aspx"><i class="fas fa-home"></i></a>
                            <span> / User Dashboard</span>
                        </div>
                    </div>

                </div>
            </div>
            <div class="container dashboard-container">



                <div class="dashboard-layout">
                    <!-- Sidebar Start -->
                    <aside class="dashboard-sidebar">
                        <div class="sidebar-card">
                            <div class="sidebar-user-profile">
                                <div class="user-avatar">
                                    <asp:Literal ID="litUserAvatar" runat="server"></asp:Literal>
                                </div>
                                <div class="user-details">
                                    <h4>
                                        <asp:Literal ID="litUserName" runat="server"></asp:Literal>
                                    </h4>
                                    <span>
                                        <asp:Literal ID="litUserEmail" runat="server"></asp:Literal>
                                    </span>
                                </div>
                            </div>

                            <nav class="sidebar-nav">
                                <ul>
                                    <li class="active">
                                        <a href="userdashboard.aspx">
                                            <i class="fas fa-home"></i> Dashboard
                                        </a>
                                    </li>
                                    <li>
                                        <a href="#">
                                            <i class="fas fa-box"></i> Order
                                        </a>
                                    </li>
                                    <li>
                                        <a href="#">
                                            <i class="fas fa-credit-card"></i> Saved Card
                                        </a>
                                    </li>
                                    <li>
                                        <a href="#">
                                            <i class="fas fa-map-marker-alt"></i> Address
                                        </a>
                                    </li>
                                    <li>
                                        <a href="#">
                                            <i class="fas fa-user"></i> Profile
                                        </a>
                                    </li>
                                    <li>
                                        <a href="#">
                                            <i class="fas fa-shield-alt"></i> Settings
                                        </a>
                                    </li>
                                </ul>
                            </nav>

                            <div class="sidebar-logout-wrapper">
                                <asp:LinkButton ID="btnLogoutDash" runat="server" OnClick="btnLogoutDash_Click"
                                    CssClass="btn-logout">
                                    <i class="fas fa-sign-out-alt"></i> Log Out
                                </asp:LinkButton>
                            </div>
                        </div>
                    </aside>
                    <!-- Sidebar End -->

                    <!-- Main Content Area Start -->
                    <main class="dashboard-main-content">
                        <div class="main-card">
                            <div class="welcome-header">
                                <h2>Welcome Back, <asp:Literal ID="litWelcomeName" runat="server">Kennedy Page
                                    </asp:Literal>
                                </h2>
                                <p>From your My Account Dashboard you have the ability to view a snapshot of your recent
                                    account activity and update your account information. Select a link below to view or
                                    edit information.</p>
                            </div>

                            <div class="dashboard-grid">
                                <!-- Card 1: Orders -->
                                <a href="#" class="dash-grid-card">
                                    <div class="dash-card-illustration">
                                        <img src="assets/images/dashboard/order.svg" alt="Orders" />
                                    </div>
                                    <h4>Orders</h4>
                                    <p>Verify the status of your order.</p>
                                </a>

                                <!-- Card 2: Wishlist -->
                                <a href="#" class="dash-grid-card">
                                    <div class="dash-card-illustration">
                                        <img src="assets/images/dashboard/wishlist.svg" alt="Wishlist" />
                                    </div>
                                    <h4>Wishlist</h4>
                                    <p>View your wishlist of saved items.</p>
                                </a>

                                <!-- Card 3: Saved Card -->
                                <a href="#" class="dash-grid-card">
                                    <div class="dash-card-illustration">
                                        <img src="assets/images/dashboard/saveCard.svg" alt="Saved Card" />
                                    </div>
                                    <h4>Saved Card</h4>
                                    <p>Keep your credit cards handy for future purchases.</p>
                                </a>

                                <!-- Card 4: Address -->
                                <a href="#" class="dash-grid-card">
                                    <div class="dash-card-illustration">
                                        <img src="assets/images/dashboard/address.svg" alt="Address" />
                                    </div>
                                    <h4>Address</h4>
                                    <p>Keep track of addresses for all your purchases.</p>
                                </a>

                                <!-- Card 5: Profile -->
                                <a href="#" class="dash-grid-card">
                                    <div class="dash-card-illustration">
                                        <img src="assets/images/dashboard/profile.svg" alt="Profile" />
                                    </div>
                                    <h4>Profile</h4>
                                    <p>Modify the information on your profile.</p>
                                </a>

                                <!-- Card 6: Privacy -->
                                <a href="#" class="dash-grid-card">
                                    <div class="dash-card-illustration">
                                        <img src="assets/images/dashboard/settings.svg" alt="Settings" />
                                    </div>
                                    <h4>Settings</h4>
                                    <p>Check your account settings</p>
                                </a>
                            </div>
                        </div>
                    </main>
                    <!-- Main Content Area End -->
                </div>

            </div>
        </section>
    </asp:Content>