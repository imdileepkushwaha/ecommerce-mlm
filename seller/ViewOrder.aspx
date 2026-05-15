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
                    <!-- Dynamic Optional Pickup Notes Input for Picked up State -->
                    <asp:Panel ID="pnlPickupNoteInput" runat="server" Visible="false" style="margin: 0 20px; display: flex; flex-direction: column; justify-content: center;">
                        <label style="font-size:0.68rem; font-weight:850; color:#64748b; text-transform:uppercase; display:block; margin-bottom:4px; letter-spacing:0.3px;">Pickup Note (Optional)</label>
                        <asp:TextBox ID="txtSellerPickupNote" runat="server" placeholder="Enter logistics tracking/note..." style="font-size:0.8rem; padding:8px 12px; border-radius:8px; border:1.5px solid #e2e8f0; width:250px; font-family:inherit; outline:none; transition: border 0.3s;"></asp:TextBox>
                    </asp:Panel>
                    
                    <asp:LinkButton ID="btnConfirmOrder" runat="server" CssClass="od-btn-action"
                        OnClick="btnConfirmOrder_Click">
                        <i class="fas fa-arrow-right"></i> Confirm order
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnRejectReturn" runat="server" CssClass="od-btn-action od-btn-cancelled"
                        OnClick="btnRejectReturn_Click" Visible="false" style="margin-left: 10px;">
                        <i class="fas fa-times"></i> Reject Return
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

        <!-- PREMIUM DETAILED RETURN LIFECYCLE (ATTACHMENT INSPIRED) -->
        <asp:Panel ID="pnlReturnDetailedFlow" runat="server" Visible="false">
            <div style="margin-top:30px; margin-bottom:12px;">
                <h3 style="font-size:1.05rem; font-weight:800; color:#0f172a; margin:0 0 2px 0;">Return process — full view</h3>
                <p style="font-size:0.78rem; color:#94a3b8; margin:0; font-weight:500;">Har return ka poora flow: steps, refund details, aur timestamps — panel khol kar dekhein.</p>
            </div>

            <div class="od-section" style="border: 1.5px solid #e2e8f0; border-radius:16px; margin-bottom:30px;">
                <!-- ACCORDION/PANEL HEADER -->
                <div class="od-sec-head" style="background:#f8fafc; padding: 14px 20px;">
                    <div style="display:flex; align-items:center; gap:12px;">
                        <div style="background:#f1f5f9; border: 1px solid #e2e8f0; border-radius:6px; width:28px; height:24px; display:flex; align-items:center; justify-content:center; color:#64748b; font-size:0.7rem;"><i class="fas fa-chevron-down"></i></div>
                        <div>
                            <span style="font-size:0.68rem; text-transform:uppercase; font-weight:850; color:#94a3b8; letter-spacing:0.5px;">Return #<asp:Literal ID="litRtnId" runat="server"></asp:Literal></span>
                            <h4 style="font-size:0.88rem; font-weight:800; color:#1e293b; margin:1px 0 0 0;"><asp:Literal ID="litRtnProductName" runat="server"></asp:Literal></h4>
                        </div>
                    </div>
                    <div style="display:flex; gap:8px;">
                        <span class="ord-pill-status" style="background:#ecfdf5; color:#059669; border: 1px solid #a7f3d0; font-size:0.72rem; font-weight:750;"><asp:Literal ID="litRtnStatusBadge" runat="server"></asp:Literal></span>
                        <span class="ord-pill-status" style="background:#f3e8ff; color:#7e22ce; border: 1px solid #e9d5ff; font-size:0.72rem; font-weight:750;"><asp:Literal ID="litRtnSubBadge" runat="server">Pickup • In Queue</asp:Literal></span>
                    </div>
                </div>
                
                <div class="od-sec-body" style="padding:22px;">
                    <!-- PROGRESS LABEL -->
                    <span style="font-size:0.65rem; text-transform:uppercase; font-weight:850; color:#94a3b8; letter-spacing:1px; display:block; margin-bottom:15px;">Progress</span>

                    <!-- SCALED NODE TIMELINE -->
                    <div class="rt-timeline-wrap">
                        <div class="rt-timeline-track">
                            <div class="rt-timeline-fill" id="divRtFill" runat="server" style="width:20%;"></div>
                        </div>
                        <div class="rt-timeline-nodes">
                            <div class="rt-node" id="nodeRt1" runat="server">
                                <div class="rt-circle"><i class="fas fa-check"></i></div>
                                <span class="rt-lbl">Requested</span>
                                <span class="rt-time"><asp:Literal ID="litRtDate1" runat="server"></asp:Literal></span>
                            </div>
                            <div class="rt-node" id="nodeRt2" runat="server">
                                <div class="rt-circle"><i class="fas fa-check"></i></div>
                                <span class="rt-lbl">Approved</span>
                                <span class="rt-time"><asp:Literal ID="litRtDate2" runat="server">--</asp:Literal></span>
                            </div>
                            <div class="rt-node" id="nodeRt3" runat="server">
                                <div class="rt-circle"><i class="fas fa-check"></i></div>
                                <span class="rt-lbl">Pickup scheduled</span>
                                <span class="rt-time"><asp:Literal ID="litRtDate3" runat="server">--</asp:Literal></span>
                            </div>
                            <div class="rt-node" id="nodeRt4" runat="server">
                                <div class="rt-circle"><i class="fas fa-check"></i></div>
                                <span class="rt-lbl">Picked up</span>
                                <span class="rt-time"><asp:Literal ID="litRtDate4" runat="server">--</asp:Literal></span>
                            </div>
                            <div class="rt-node" id="nodeRt5" runat="server">
                                <div class="rt-circle"><i class="fas fa-check"></i></div>
                                <span class="rt-lbl">Refunded</span>
                                <span class="rt-time"><asp:Literal ID="litRtDate5" runat="server">--</asp:Literal></span>
                            </div>
                        </div>
                    </div>

                    <!-- DETAILS METRIC DECK CONTAINER -->
                    <div style="background:#f8fafc; border-radius:12px; padding:18px; border: 1.5px solid #f1f5f9; margin-top:25px;">
                        <span style="font-size:0.68rem; text-transform:uppercase; font-weight:850; color:#64748b; letter-spacing:0.5px; display:block; margin-bottom:12px;">Refund & Order</span>
                        
                        <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap:10px; margin-bottom:12px;">
                            <div style="background:#ffffff; border: 1.5px solid #e2e8f0; padding:10px 14px; border-radius:10px;">
                                <span style="font-size:0.65rem; font-weight:800; color:#94a3b8; text-transform:uppercase;">Refund Amount</span>
                                <div style="font-size:0.95rem; font-weight:800; color:#059669; margin-top:3px;">₹ <asp:Literal ID="litRtAmount" runat="server"></asp:Literal></div>
                            </div>
                            <div style="background:#ffffff; border: 1.5px solid #e2e8f0; padding:10px 14px; border-radius:10px;">
                                <span style="font-size:0.65rem; font-weight:800; color:#94a3b8; text-transform:uppercase;">Refund Mode</span>
                                <div style="font-size:0.88rem; font-weight:700; color:#334155; margin-top:3px;"><asp:Literal ID="litRtMode" runat="server"></asp:Literal></div>
                            </div>
                            <div style="background:#ffffff; border: 1.5px solid #e2e8f0; padding:10px 14px; border-radius:10px;">
                                <span style="font-size:0.65rem; font-weight:800; color:#94a3b8; text-transform:uppercase;">Order Ref</span>
                                <div style="font-size:0.88rem; font-weight:700; color:#334155; margin-top:3px;"><asp:Literal ID="litRtOrderRef" runat="server"></asp:Literal></div>
                            </div>
                            <div style="background:#ffffff; border: 1.5px solid #e2e8f0; padding:10px 14px; border-radius:10px;">
                                <span style="font-size:0.65rem; font-weight:800; color:#94a3b8; text-transform:uppercase;">Reason for Request</span>
                                <div style="font-size:0.82rem; font-weight:700; color:#475569; margin-top:3px;"><asp:Literal ID="litRtReason" runat="server"></asp:Literal></div>
                            </div>
                        </div>

                        <div style="background:#ffffff; border: 1.5px solid #e2e8f0; padding:10px 14px; border-radius:10px;">
                            <span style="font-size:0.65rem; font-weight:800; color:#94a3b8; text-transform:uppercase;">Pickup Note / Message</span>
                            <div style="font-size:0.82rem; font-weight:550; color:#64748b; margin-top:4px; line-height:1.4;"><asp:Literal ID="litRtPickupNote" runat="server">—</asp:Literal></div>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

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