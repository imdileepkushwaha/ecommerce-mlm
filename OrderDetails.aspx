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
                            
                            <!-- ONLINE REFUND ALIGNMENT SLA BANNER (DYNAMIC) -->
                            <asp:Panel ID="pnlRefundBanner" runat="server" Visible="false">
                                <div style="display:flex; align-items:center; gap:12px; background:#fef2f2; border:1px solid #fecaca; border-radius:12px; padding:16px; margin-bottom:25px;">
                                    <div style="background:#fee2e2; color:#dc2626; font-size:1.1rem; border-radius:50%; width:36px; height:36px; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                                        <i class="fas fa-info-circle"></i>
                                    </div>
                                    <div>
                                        <h5 style="margin:0 0 2px 0; font-size:0.88rem; font-weight:800; color:#991b1b;">Order Cancelled</h5>
                                        <p style="margin:0; font-size:0.78rem; font-weight:550; color:#b91c1c; line-height:1.4;">Aapka order successfully cancel ho chuka hai. Kyunki aapne online payment kiya tha, refund <strong>5 working days</strong> ke andar aapke same original source account mein transfer kar diya jayega.</p>
                                    </div>
                                </div>
                            </asp:Panel>

                            <asp:Panel ID="pnlCancelRequestedBanner" runat="server" Visible="false">
                                <div style="display:flex; align-items:center; gap:12px; background:#fffbeb; border:1px solid #fde68a; border-radius:12px; padding:16px; margin-bottom:25px;">
                                    <div style="background:#fef3c7; color:#d97706; font-size:1.1rem; border-radius:50%; width:36px; height:36px; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                                        <i class="fas fa-clock"></i>
                                    </div>
                                    <div>
                                        <h5 style="margin:0 0 2px 0; font-size:0.88rem; font-weight:800; color:#92400e;">Cancellation Request Sent</h5>
                                        <p style="margin:0; font-size:0.78rem; font-weight:550; color:#b45309; line-height:1.4;">Aapki order cancellation request seller ko bhej di gayi hai. Seller ke confirmation/approval ke baad order fully cancel ho jayega.</p>
                                    </div>
                                </div>
                            </asp:Panel>

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

                            <!-- PREMIUM DETAILED RETURN LIFECYCLE (ATTACHMENT INSPIRED) -->
                            <asp:Panel ID="pnlReturnDetailedFlow" runat="server" Visible="false">
                                <div style="margin-top:30px; margin-bottom:12px;">
                                    <h3 style="font-size:1.05rem; font-weight:800; color:#0f172a; margin:0 0 2px 0;">Return process — full view</h3>
                                    <p style="font-size:0.78rem; color:#94a3b8; margin:0; font-weight:500;">Har return ka poora flow: steps, refund details, aur timestamps — panel khol kar dekhein.</p>
                                </div>

                                <div style="background:#ffffff; border: 1.5px solid #e2e8f0; border-radius:16px; margin-bottom:30px; box-shadow:0 4px 20px rgba(0,0,0,0.02); overflow:hidden;">
                                    <!-- ACCORDION/PANEL HEADER -->
                                    <div style="background:#f8fafc; padding: 14px 20px; border-bottom: 1px solid #ececec; display:flex; justify-content:space-between; align-items:center;">
                                        <div style="display:flex; align-items:center; gap:12px;">
                                            <div style="background:#f1f5f9; border: 1px solid #e2e8f0; border-radius:6px; width:28px; height:24px; display:flex; align-items:center; justify-content:center; color:#64748b; font-size:0.7rem;"><i class="fas fa-chevron-down"></i></div>
                                            <div>
                                                <span style="font-size:0.68rem; text-transform:uppercase; font-weight:850; color:#94a3b8; letter-spacing:0.5px;">Return #<asp:Literal ID="litRtnId" runat="server"></asp:Literal></span>
                                                <h4 style="font-size:0.88rem; font-weight:800; color:#1e293b; margin:1px 0 0 0;"><asp:Literal ID="litRtnProductName" runat="server"></asp:Literal></h4>
                                            </div>
                                        </div>
                                        <div style="display:flex; gap:8px;">
                                            <span class="ord-pill-status" style="background:#ecfdf5; color:#059669; border: 1px solid #a7f3d0; font-size:0.72rem; font-weight:750; border-radius:20px;"><asp:Literal ID="litRtnStatusBadge" runat="server"></asp:Literal></span>
                                            <span class="ord-pill-status" style="background:#f3e8ff; color:#7e22ce; border: 1px solid #e9d5ff; font-size:0.72rem; font-weight:750; border-radius:20px;"><asp:Literal ID="litRtnSubBadge" runat="server">Pickup • In Queue</asp:Literal></span>
                                        </div>
                                    </div>
                                    
                                    <div style="padding:22px;">
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
                                <asp:LinkButton ID="lnkCancelOrder" runat="server" Visible="false" CssClass="btn-action-pill btn-act-cancel" OnClientClick="openCancelModal(); return false;">
                                    <i class="fas fa-times-circle"></i> Cancel Order
                                </asp:LinkButton>
                                
                                <asp:LinkButton ID="lnkReturnOrder" runat="server" Visible="false" CssClass="btn-action-pill btn-act-return" OnClientClick="openReturnModal(); return false;">
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

    <!-- PREMIUM CUSTOM RETURN MODAL (User Intake Popup) -->
    <div id="divReturnModal" class="rt-modal-overlay" style="display:none;">
        <div class="rt-modal-card">
            <div class="rt-modal-hdr">
                <h5><i class="fas fa-rotate-left"></i> Request Return / Replace</h5>
                <button type="button" class="rt-modal-close" onclick="closeReturnModal()">&times;</button>
            </div>
            <div class="rt-modal-body">
                <p style="font-size:0.82rem; color:#64748b; margin-bottom:18px; line-height:1.5;">Hamare support engine ko return process karne ke liye sahi reason aur problem description share karein.</p>
                
                <div class="rt-form-grp">
                    <label for='<%= ddlReturnReason.ClientID %>'>Reason for Return</label>
                    <asp:DropDownList ID="ddlReturnReason" runat="server" CssClass="rt-form-ctrl">
                        <asp:ListItem Value="" Text="-- Select Return Reason --"></asp:ListItem>
                        <asp:ListItem Value="Size/Fit issue" Text="Size/Fit issue"></asp:ListItem>
                        <asp:ListItem Value="Damaged product" Text="Damaged product"></asp:ListItem>
                        <asp:ListItem Value="Wrong item received" Text="Wrong item received"></asp:ListItem>
                        <asp:ListItem Value="Quality not as expected" Text="Quality not as expected"></asp:ListItem>
                        <asp:ListItem Value="Other" Text="Other (Self explanation)"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="rt-form-grp" style="margin-top:16px;">
                    <label for='<%= txtReturnMessage.ClientID %>'>Detailed Message (Optional)</label>
                    <asp:TextBox ID="txtReturnMessage" runat="server" TextMode="MultiLine" Rows="4" CssClass="rt-form-ctrl" placeholder="Write any specific issue details here..."></asp:TextBox>
                </div>
            </div>
            <div class="rt-modal-ftr">
                <button type="button" class="rt-btn-cancel" onclick="closeReturnModal()">Cancel</button>
                <asp:Button ID="btnSubmitReturn" runat="server" Text="Confirm Return" CssClass="rt-btn-submit" OnClick="btnSubmitReturn_Click" OnClientClick="return validateReturnSubmission();" />
            </div>
        </div>
    </div>

    <!-- PREMIUM CUSTOM CANCEL MODAL -->
    <div id="divCancelModal" class="rt-modal-overlay" style="display:none;">
        <div class="rt-modal-card">
            <div class="rt-modal-hdr" style="border-bottom-color:#fee2e2;">
                <h5 style="color:#dc2626;"><i class="fas fa-times-circle"></i> Request Order Cancellation</h5>
                <button type="button" class="rt-modal-close" onclick="closeCancelModal()">&times;</button>
            </div>
            <div class="rt-modal-body" style="padding-top:18px;">
                <p style="font-size:0.82rem; color:#64748b; margin-bottom:18px; line-height:1.5;">Aapke order ko cancel karne ki request seller ko forward ki jayegi. Sahi feedback select karein taaki process complete kiya ja sake.</p>
                
                <div class="rt-form-grp">
                    <label for='<%= ddlCancelReason.ClientID %>'>Cancellation Reason</label>
                    <asp:DropDownList ID="ddlCancelReason" runat="server" CssClass="rt-form-ctrl">
                        <asp:ListItem Value="" Text="-- Select Reason --"></asp:ListItem>
                        <asp:ListItem Value="Ordered by mistake" Text="Ordered by mistake"></asp:ListItem>
                        <asp:ListItem Value="Delayed delivery expected" Text="Delayed delivery expected"></asp:ListItem>
                        <asp:ListItem Value="Changed my mind" Text="Changed my mind"></asp:ListItem>
                        <asp:ListItem Value="Found cheaper elsewhere" Text="Found cheaper elsewhere"></asp:ListItem>
                        <asp:ListItem Value="Other reason" Text="Other reason"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="rt-form-grp">
                    <label for='<%= txtCancelMessage.ClientID %>'>Message / Feedback (Optional)</label>
                    <asp:TextBox ID="txtCancelMessage" runat="server" TextMode="MultiLine" Rows="3" CssClass="rt-form-ctrl" placeholder="Explain briefly why you wish to cancel..."></asp:TextBox>
                </div>
            </div>
            <div class="rt-modal-ftr">
                <button type="button" class="rt-btn-cancel" onclick="closeCancelModal()">Go Back</button>
                <asp:Button ID="btnSubmitCancel" runat="server" Text="Submit Request" CssClass="rt-btn-submit" style="background:#dc2626; border-color:#dc2626;" OnClick="btnSubmitCancel_Click" OnClientClick="return validateCancelSubmission();" />
            </div>
        </div>
    </div>

    <!-- MODAL EXECUTION SCRIPT -->
    <script type="text/javascript">
        function openReturnModal() {
            var modal = document.getElementById('divReturnModal');
            if (modal) modal.style.display = 'flex';
        }
        function closeReturnModal() {
            var modal = document.getElementById('divReturnModal');
            if (modal) modal.style.display = 'none';
        }
        function validateReturnSubmission() {
            var ddl = document.getElementById('<%= ddlReturnReason.ClientID %>');
            if (!ddl || ddl.value === "") {
                alert('Please choose a valid reason to process the return request.');
                ddl.focus();
                return false;
            }
            return true;
        }

        function openCancelModal() {
            var modal = document.getElementById('divCancelModal');
            if (modal) modal.style.display = 'flex';
        }
        function closeCancelModal() {
            var modal = document.getElementById('divCancelModal');
            if (modal) modal.style.display = 'none';
        }
        function validateCancelSubmission() {
            var ddl = document.getElementById('<%= ddlCancelReason.ClientID %>');
            if (!ddl || ddl.value === "") {
                alert('Please select a reason to process the cancellation request.');
                ddl.focus();
                return false;
            }
            return true;
        }

        // Global Close upon overlay background click
        window.addEventListener('click', function (event) {
            var rtMod = document.getElementById('divReturnModal');
            var cnMod = document.getElementById('divCancelModal');
            if (event.target === rtMod) closeReturnModal();
            if (event.target === cnMod) closeCancelModal();
        });
    </script>
</asp:Content>
