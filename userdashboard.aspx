<%@ Page Title="User Dashboard" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true"
    CodeFile="userdashboard.aspx.cs" Inherits="ecommerce_mlm.userdashboard" %>
    <%@ Register Src="~/UserSidebar.ascx" TagPrefix="uc" TagName="UserSidebar" %>

        <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
            <!-- Head Content -->
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
                        <uc:UserSidebar runat="server" ID="UserSidebar" />
                        <!-- Sidebar End -->

                        <!-- Main Content Area Start -->
                        <main class="dashboard-main-content">
                            <div class="main-card">
                                <div class="welcome-header">
                                    <h2>Welcome Back, <asp:Literal ID="litWelcomeName" runat="server">Kennedy Page
                                        </asp:Literal>
                                    </h2>
                                    <p>From your My Account Dashboard you have the ability to view a snapshot of your
                                        recent
                                        account activity and update your account information. Select a link below to
                                        view or
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
                                    <a href="Wishlist.aspx" class="dash-grid-card">
                                        <div class="dash-card-illustration">
                                            <img src="assets/images/dashboard/wishlist.svg" alt="Wishlist" />
                                        </div>
                                        <h4>Wishlist</h4>
                                        <p>View your wishlist of saved items.</p>
                                    </a>

                                    <!-- Card 3: Reviews -->
                                    <a href="#" class="dash-grid-card">
                                        <div class="dash-card-illustration">
                                            <img src="assets/images/dashboard/notification.svg" alt="Reviews" />
                                        </div>
                                        <h4>Reviews</h4>
                                        <p>Reviews for the products you purchased.</p>
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
                                    <a href="UserProfile.aspx" class="dash-grid-card">
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