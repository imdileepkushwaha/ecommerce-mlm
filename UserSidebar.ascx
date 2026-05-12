<%@ Control Language="C#" AutoEventWireup="true" CodeFile="UserSidebar.ascx.cs" Inherits="ecommerce_mlm.UserSidebar" %>

<aside class="dashboard-sidebar">
    <div class="sidebar-card">
        <div class="sidebar-user-profile">
            <div class="user-avatar">
                <asp:Literal ID="litUserAvatar" runat="server"></asp:Literal>
            </div>
            <div class="user-details">
                <h4><asp:Literal ID="litUserName" runat="server"></asp:Literal></h4>
                <span><asp:Literal ID="litUserEmail" runat="server"></asp:Literal></span>
            </div>
        </div>

        <nav class="sidebar-nav">
            <ul>
                <li class='<%= GetActiveClass("userdashboard.aspx") %>'>
                    <a href="userdashboard.aspx"><i class="fas fa-home"></i> Dashboard</a>
                </li>
                <li class='<%= GetActiveClass("Orders.aspx") %>'>
                    <a href="#"><i class="fas fa-box"></i> Order</a>
                </li>
                <li class='<%= GetActiveClass("Wishlist.aspx") %>'>
                    <a href="Wishlist.aspx"><i class="fas fa-heart"></i> Wishlist</a>
                </li>
                <li>
                    <a href="#"><i class="fas fa-map-marker-alt"></i> Address</a>
                </li>
                <li>
                    <a href="#"><i class="fas fa-users"></i> My Team</a>
                </li>
                <li>
                    <a href="#"><i class="fas fa-wallet"></i> My Income</a>
                </li>
                <li>
                    <a href="#"><i class="fas fa-trophy"></i> Rewards</a>
                </li>
                <li>
                    <a href="#"><i class="fas fa-star"></i> Reviews</a>
                </li>
                <li class='<%= GetActiveClass("UserProfile.aspx") %>'>
                    <a href="UserProfile.aspx"><i class="fas fa-user"></i> Profile</a>
                </li>
                <li>
                    <a href="#"><i class="fas fa-shield-alt"></i> Settings</a>
                </li>
            </ul>
        </nav>

        <div class="sidebar-logout-wrapper">
            <asp:LinkButton ID="btnLogoutDash" runat="server" OnClick="btnLogoutDash_Click" CssClass="btn-logout">
                <i class="fas fa-sign-out-alt"></i> Log Out
            </asp:LinkButton>
        </div>
    </div>
</aside>
