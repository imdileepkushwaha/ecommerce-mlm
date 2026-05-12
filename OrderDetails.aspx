<%@ Page Title="Order Details" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true" CodeFile="OrderDetails.aspx.cs" Inherits="ecommerce_mlm.OrderDetails" %>
<%@ Register Src="~/UserSidebar.ascx" TagPrefix="uc" TagName="UserSidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <section class="dashboard-wrapper">
        <!-- Breadcrumb -->
        <div class="dashboard-breadcrumb">
            <div class="container">
                <div class="dashboard-breadcrumb-inner">
                    <div class="breadcrumb-left">
                        <h3>Order Detail</h3>
                    </div>
                    <div class="breadcrumb-right">
                        <a href="index.aspx"><i class="fas fa-home"></i></a>
                        <a href="UserOrders.aspx"> / Orders</a>
                        <span> / #ORD<asp:Literal ID="litHeadOrderId" runat="server"></asp:Literal></span>
                    </div>
                </div>
            </div>
        </div>

        <div class="container dashboard-container dash-spacer">
            <div class="dashboard-layout">
                
                <uc:UserSidebar runat="server" ID="UserSidebar" />

                <main class="dashboard-main-content">
                    <div class="main-card main-card-padded">
                        
                        <div class="section-title section-title-bordered">
                            <div><i class="fas fa-receipt"></i> Order Status Tracking</div>
                            <a href="UserOrders.aspx" class="btn-back-link"><i class="fas fa-arrow-left"></i> Back to List</a>
                        </div>

                        <asp:Panel ID="pnlContent" runat="server">
                            
                            <!-- 1. Summary Ribbon -->
                            <div class="order-det-summary">
                                <div class="order-det-pill">
                                    <span class="lbl">Order Number</span>
                                    <span class="val">#ORD<asp:Literal ID="litOrderNo" runat="server"></asp:Literal></span>
                                </div>
                                <div class="order-det-pill">
                                    <span class="lbl">Date Placed</span>
                                    <span class="val"><asp:Literal ID="litOrderDate" runat="server"></asp:Literal></span>
                                </div>
                                <div class="order-det-pill">
                                    <span class="lbl">Current Status</span>
                                    <asp:Literal ID="litStatusBadge" runat="server"></asp:Literal>
                                </div>
                                <div class="order-det-pill">
                                    <span class="lbl">Grand Total</span>
                                    <span class="val val-accent">₹ <asp:Literal ID="litGrandTotalHero" runat="server"></asp:Literal></span>
                                </div>
                            </div>

                            <!-- 2. Timeline Tracking Visualizer -->
                            <div class="order-timeline-wrapper">
                                <div class="timeline-steps">
                                    <!-- The width of this line is controlled from C# backend code to fill visually -->
                                    <asp:Literal ID="litProgressLine" runat="server"></asp:Literal>
                                    
                                    <div class="tl-step <%= GetStepClass("placed") %>">
                                        <div class="tl-icon"><i class="fas fa-box"></i></div>
                                        <div class="tl-txt">Placed</div>
                                    </div>
                                    <div class="tl-step <%= GetStepClass("processing") %>">
                                        <div class="tl-icon"><i class="fas fa-cogs"></i></div>
                                        <div class="tl-txt">Processing</div>
                                    </div>
                                    <div class="tl-step <%= GetStepClass("shipped") %>">
                                        <div class="tl-icon"><i class="fas fa-truck"></i></div>
                                        <div class="tl-txt">Shipped</div>
                                    </div>
                                    <div class="tl-step <%= GetStepClass("delivered") %>">
                                        <div class="tl-icon"><i class="fas fa-check-circle"></i></div>
                                        <div class="tl-txt">Delivered</div>
                                    </div>
                                </div>
                            </div>

                            <!-- 3. Split Grid: Address & Payment -->
                            <div class="order-split-grid">
                                <div class="order-info-box">
                                    <h5><i class="fas fa-map-marker-alt"></i> Shipping Address</h5>
                                    <div class="address-block">
                                        <strong><asp:Literal ID="litAddrName" runat="server"></asp:Literal></strong>
                                        <asp:Literal ID="litAddrLine" runat="server"></asp:Literal><br />
                                        <asp:Literal ID="litAddrCity" runat="server"></asp:Literal>, <asp:Literal ID="litAddrState" runat="server"></asp:Literal> - <asp:Literal ID="litAddrZip" runat="server"></asp:Literal><br />
                                        <span style="display:inline-block; margin-top:5px; color:#64748b;"><i class="fas fa-phone-alt" style="font-size:0.8rem;"></i> <asp:Literal ID="litAddrPhone" runat="server"></asp:Literal></span>
                                    </div>
                                </div>
                                
                                <div class="order-info-box">
                                    <h5><i class="fas fa-file-invoice-dollar"></i> Price Details</h5>
                                    <div class="price-summary-row">
                                        <span>Subtotal</span>
                                        <span>₹ <asp:Literal ID="litSubtotal" runat="server"></asp:Literal></span>
                                    </div>
                                    <div class="price-summary-row">
                                        <span>Discount Applied</span>
                                        <span class="text-discount">-₹ <asp:Literal ID="litDiscount" runat="server"></asp:Literal></span>
                                    </div>
                                    <div class="price-summary-row">
                                        <span>Shipping Fee</span>
                                        <span class="text-discount">FREE</span>
                                    </div>
                                    <div class="price-summary-row grand-total">
                                        <span>Total Paid</span>
                                        <span>₹ <asp:Literal ID="litGrandTotalFinal" runat="server"></asp:Literal></span>
                                    </div>
                                </div>
                            </div>

                            <!-- 4. Purchased Items List -->
                            <h5 style="font-weight:700; color:#1e293b; margin-bottom:15px;">Items Purchased (<asp:Literal ID="litItemCount" runat="server"></asp:Literal>)</h5>
                            <div class="order-items-list">
                                <asp:Repeater ID="rptItems" runat="server">
                                    <ItemTemplate>
                                        <div class="order-item-row">
                                            <img src='<%# ResolveUrl(Eval("MainImage") != DBNull.Value ? Eval("MainImage").ToString() : "https://via.placeholder.com/100") %>' onerror="this.onerror=null; this.src='https://via.placeholder.com/100';" class="item-thumb" alt="product" />
                                            <div class="item-meta">
                                                <h6><%# Eval("ProductName") %></h6>
                                                <p>Qty: <strong><%# Eval("Quantity") %></strong></p>
                                            </div>
                                            <div class="item-price-grp">
                                                <span class="main-pr">₹ <%# String.Format("{0:n2}", Convert.ToDecimal(Eval("UnitPrice")) * Convert.ToInt32(Eval("Quantity"))) %></span>
                                                <span class="sub-pr">₹ <%# String.Format("{0:n2}", Eval("UnitPrice")) %> each</span>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>

                            <!-- 5. Sticky Action Footer (Conditional Buttons) -->
                            <div class="order-actions-footer">
                                <asp:LinkButton ID="lnkCancelOrder" runat="server" Visible="false" CssClass="btn-action-pill btn-act-cancel" OnClick="lnkCancelOrder_Click" OnClientClick="return confirm('Are you sure you want to cancel this order?');">
                                    <i class="fas fa-times-circle"></i> Cancel Order
                                </asp:LinkButton>
                                
                                <asp:LinkButton ID="lnkReturnOrder" runat="server" Visible="false" CssClass="btn-action-pill btn-act-return" OnClick="lnkReturnOrder_Click">
                                    <i class="fas fa-undo"></i> Return / Replace
                                </asp:LinkButton>

                                <a href="ProductList.aspx" class="btn-action-pill btn-act-review" runat="server" id="btnWriteReview" Visible="false">
                                    <i class="fas fa-star"></i> Write Review
                                </a>

                                <a href="Contact.aspx?subject=OrderHelp" class="btn-action-pill btn-act-help">
                                    <i class="fas fa-headset"></i> Need Help?
                                </a>
                            </div>

                        </asp:Panel>

                        <!-- Handle Invalid ID case gracefully -->
                        <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="empty-placeholder-wrap">
                            <div class="empty-icon-lg"><i class="fas fa-exclamation-triangle" style="color:#f59e0b;"></i></div>
                            <h3 class="empty-title-dark">Order Not Found</h3>
                            <p class="empty-subtitle">The order details you are looking for could not be retrieved.</p>
                            <a href="UserOrders.aspx" class="btn-save btn-inline-clean">Return to Orders</a>
                        </asp:Panel>

                    </div>
                </main>
            </div>
        </div>
    </section>
</asp:Content>
