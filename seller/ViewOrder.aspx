<%@ Page Title="Order Details" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true"
    CodeFile="ViewOrder.aspx.cs" Inherits="EcommerceWebsite.SellerViewOrder" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- 1. HEADER CONSOLE -->
        <div class="od-page-header">
            <div class="od-header-left">
                <h2>Order details</h2>
                <p>Order <strong>#<asp:Literal ID="litOrderRef" runat="server"></asp:Literal></strong> · Placed
                    <asp:Literal ID="litOrderDate" runat="server"></asp:Literal>
                </p>
            </div>
            <div>
                <a href="Orders.aspx" class="od-btn-back">Back to orders</a>
            </div>
        </div>

        <!-- 2. ACTION BANNER (DYNAMIC CONDITIONAL) -->
        <div class="od-section" runat="server" id="pnlActionBox" visible="false">
            <div class="od-sec-head">
                <div class="od-sec-title-box">
                    <h3>Update Order Status</h3>
                    <p>Quick action: next allowed step par click karke order status update karein.</p>
                </div>
            </div>
            <div class="od-sec-body">
                <div class="od-action-banner">
                    <div class="od-banner-left">
                        <div class="od-banner-ico"><i class="fas fa-circle-info"></i></div>
                        <div class="od-banner-txt">
                            <span class="od-banner-lbl">One-click status update available.</span>
                            <div class="od-flow-path">
                                <span class="od-flow-step active">
                                    <asp:Literal ID="litFlowSource" runat="server"></asp:Literal>
                                </span>
                                <i class="fas fa-arrow-right od-flow-arrow"></i>
                                <span class="od-flow-step">
                                    <asp:Literal ID="litFlowTarget" runat="server"></asp:Literal>
                                </span>
                            </div>
                        </div>
                    </div>
                    <asp:LinkButton ID="btnConfirmOrder" runat="server" CssClass="od-btn-action"
                        OnClick="btnConfirmOrder_Click">
                        <i class="fas fa-arrow-right"></i> Confirm order
                    </asp:LinkButton>
                </div>
            </div>
        </div>

        <!-- 3. SUMMARY CONSOLE -->
        <div class="od-section">
            <div class="od-sec-head">
                <div class="od-sec-title-box">
                    <h3>Summary</h3>
                    <p>Customer, payment, amounts, aur shipping — ek nazar me.</p>
                </div>
                <span class="ord-pill-status ord-status-processing">
                    <asp:Literal ID="litSumStatus" runat="server"></asp:Literal>
                </span>
            </div>
            <div class="od-sec-body">
                <div class="od-summary-grid">
                    <div class="od-summary-box">
                        <span class="od-sub-lbl">Customer</span>
                        <div class="od-sub-val">
                            <asp:Literal ID="litCustName" runat="server"></asp:Literal>
                        </div>
                    </div>
                    <div class="od-summary-box">
                        <span class="od-sub-lbl">Email</span>
                        <div class="od-sub-val" style="font-size:0.85rem;">
                            <asp:Literal ID="litCustEmail" runat="server"></asp:Literal>
                        </div>
                    </div>
                    <div class="od-summary-box">
                        <span class="od-sub-lbl">Order total</span>
                        <div class="od-sub-val">
                            <asp:Literal ID="litOrderTotal" runat="server"></asp:Literal>
                        </div>
                    </div>
                    <div class="od-summary-box highlight">
                        <span class="od-sub-lbl" style="color:#ef4444;">Your items total</span>
                        <div class="od-sub-val">
                            <asp:Literal ID="litSellerItemsTotal" runat="server"></asp:Literal>
                        </div>
                    </div>
                    <div class="od-summary-box">
                        <span class="od-sub-lbl">Payment method</span>
                        <div class="od-sub-val">
                            <asp:Literal ID="litPaymentMode" runat="server"></asp:Literal>
                        </div>
                    </div>
                    <div class="od-full-row-box">
                        <span class="od-sub-lbl">Shipping address</span>
                        <div class="od-sub-val" style="font-size:0.88rem; font-weight:600; color:#475569;">
                            <asp:Literal ID="litShippingAddress" runat="server"></asp:Literal>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 4. DELIVERY TRACKER & TIMELINE -->
        <div class="od-section">
            <div class="od-sec-head">
                <div class="od-sec-title-box">
                    <h3>Delivery Details</h3>
                    <p>Delivery stage, ETA aur address ek jagah.</p>
                </div>
            </div>
            <div class="od-sec-body">
                <div class="od-summary-grid">
                    <div class="od-summary-box">
                        <span class="od-sub-lbl">Current stage</span>
                        <div class="od-sub-val" style="color:#ea580c;">
                            <asp:Literal ID="litCurrentStage" runat="server">Preparing order</asp:Literal>
                        </div>
                    </div>
                    <div class="od-summary-box">
                        <span class="od-sub-lbl">ETA</span>
                        <div class="od-sub-val" style="color:#ea580c;">
                            <asp:Literal ID="litEta" runat="server">Expected Soon</asp:Literal>
                        </div>
                    </div>
                </div>

                <div class="od-full-row-box" style="margin-top:16px; margin-bottom:16px;">
                    <span class="od-sub-lbl">Delivery address</span>
                    <div class="od-sub-val" style="font-size:0.88rem; font-weight:600; color:#475569;">
                        <asp:Literal ID="litDeliveryAddress" runat="server"></asp:Literal>
                    </div>
                </div>

                <div class="od-summary-box" style="display:inline-block; min-width:200px;">
                    <span class="od-sub-lbl">Placed on</span>
                    <div class="od-sub-val">
                        <asp:Literal ID="litPlacedDateFormatted" runat="server"></asp:Literal>
                    </div>
                </div>

                <!-- TRACKER BAR STEPPER -->
                <div class="od-stepper-row">
                    <div class="od-stepper-bar-frame">
                        <div class='<asp:Literal ID="clsTrack1" runat="server"></asp:Literal>'></div>
                        <div class='<asp:Literal ID="clsTrack2" runat="server"></asp:Literal>'></div>
                        <div class='<asp:Literal ID="clsTrack3" runat="server"></asp:Literal>'></div>
                        <div class='<asp:Literal ID="clsTrack4" runat="server"></asp:Literal>'></div>
                        <div class='<asp:Literal ID="clsTrack5" runat="server"></asp:Literal>'></div>
                    </div>
                    <div class="od-stepper-captions">
                        <div class="od-step-caption">
                            <span class='<asp:Literal ID="clsCap1" runat="server"></asp:Literal>'>
                                <asp:Literal ID="litCapName1" runat="server">Placed</asp:Literal> <i
                                    class="fas fa-circle-dot" style="font-size:0.6rem;"></i>
                            </span>
                            <span class="od-cap-sub">
                                <asp:Literal ID="litStepDate1" runat="server"></asp:Literal>
                            </span>
                        </div>
                        <div class="od-step-caption">
                            <span class='<asp:Literal ID="clsCap2" runat="server"></asp:Literal>'>
                                <asp:Literal ID="litCapName2" runat="server">Confirmed</asp:Literal>
                            </span>
                            <span class="od-cap-sub">
                                <asp:Literal ID="litStepDate2" runat="server"></asp:Literal>
                            </span>
                        </div>
                        <div class="od-step-caption">
                            <span class='<asp:Literal ID="clsCap3" runat="server"></asp:Literal>'>
                                <asp:Literal ID="litCapName3" runat="server">Shipped</asp:Literal>
                            </span>
                            <span class="od-cap-sub">
                                <asp:Literal ID="litStepDate3" runat="server"></asp:Literal>
                            </span>
                        </div>
                        <div class="od-step-caption">
                            <span class='<asp:Literal ID="clsCap4" runat="server"></asp:Literal>'>
                                <asp:Literal ID="litCapName4" runat="server">Out for delivery</asp:Literal>
                            </span>
                            <span class="od-cap-sub">
                                <asp:Literal ID="litStepDate4" runat="server"></asp:Literal>
                            </span>
                        </div>
                        <div class="od-step-caption">
                            <span class='<asp:Literal ID="clsCap5" runat="server"></asp:Literal>'>
                                <asp:Literal ID="litCapName5" runat="server">Delivered</asp:Literal>
                            </span>
                            <span class="od-cap-sub">
                                <asp:Literal ID="litStepDate5" runat="server"></asp:Literal>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 5. MERCHANDISE ITEM DESK -->
        <div class="od-section">
            <div class="od-sec-head">
                <div class="od-sec-title-box">
                    <h3>Order Items</h3>
                    <p>Sirf aapke catalogue ki lines — price, qty, aur live product link.</p>
                </div>
            </div>
            <div class="od-table-wrap">
                <asp:Repeater ID="rptOrderItems" runat="server">
                    <HeaderTemplate>
                        <table class="od-table">
                            <thead>
                                <tr>
                                    <th>ITEM</th>
                                    <th>CATEGORY</th>
                                    <th>VARIANT</th>
                                    <th>STATUS</th>
                                    <th>PRICE</th>
                                    <th>QTY</th>
                                    <th>LINE TOTAL</th>
                                    <th>ACTIONS</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td style="width:40%;">
                                <div class="od-item-cell">
                                    <div class="od-item-thumb">
                                        <%# GetItemImage(Eval("MainImage")) %>
                                    </div>
                                    <div class="od-item-name">
                                        <%# Eval("ProductName") %>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="od-cell-val-sub" style="text-transform:lowercase;">
                                    <%# Eval("Category") %>
                                </span>
                            </td>
                            <td>
                                <span class="od-cell-val-sub">
                                    <%# Eval("ColorName") %>
                                </span>
                            </td>
                            <td>
                                <%# GetOrderBadgeSmall(Eval("OrderStatus")) %>
                            </td>
                            <td>
                                <span class="od-cell-val">₹<%# Convert.ToDecimal(Eval("UnitPrice")).ToString("N0") %>
                                        </span>
                            </td>
                            <td>
                                <span class="od-cell-val">
                                    <%# Eval("Quantity") %>
                                </span>
                            </td>
                            <td>
                                <strong class="od-cell-val" style="color:#0f172a;">₹<%#
                                        (Convert.ToDecimal(Eval("UnitPrice")) *
                                        Convert.ToInt32(Eval("Quantity"))).ToString("N0") %></strong>
                            </td>
                            <td>
                                <a href='../ProductDetails.aspx?slug=<%# Eval("Slug") %>' target="_blank"
                                    class="ord-act-btn ord-act-view" title="Preview Live Store Listing">
                                    <i class="fas fa-arrow-up-right-from-square" style="font-size:0.75rem;"></i>
                                </a>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>

    </asp:Content>