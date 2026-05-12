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
                <li class='<%= GetActiveClass("UserOrders.aspx") %>'>
                    <a href="UserOrders.aspx"><i class="fas fa-box"></i> Order</a>
                </li>
                <li class='<%= GetActiveClass("Wishlist.aspx") %>'>
                    <a href="Wishlist.aspx"><i class="fas fa-heart"></i> Wishlist</a>
                </li>
                <li class='<%= GetActiveClass("userTree.aspx") %>'>
                    <a href="userTree.aspx"><i class="fas fa-users"></i> My Team</a>
                </li>
                <li class='<%= GetActiveClass("userIncome.aspx") %>'>
                    <a href="userIncome.aspx"><i class="fas fa-wallet"></i> My Income</a>
                </li>
                <li class='<%= GetActiveClass("userRewards.aspx") %>'>
                    <a href="userRewards.aspx"><i class="fas fa-trophy"></i> Rewards</a>
                </li>
                <li class='<%= GetActiveClass("MyReviews.aspx") %>'>
                    <a href="MyReviews.aspx"><i class="fas fa-star"></i> Reviews</a>
                </li>
                <li class='<%= GetActiveClass("UserProfile.aspx") %>'>
                    <a href="UserProfile.aspx"><i class="fas fa-user"></i> Profile</a>
                </li>
                <li class='<%= GetActiveClass("UserSettings.aspx") %>'>
                    <a href="UserSettings.aspx"><i class="fas fa-cog"></i> Settings</a>
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
