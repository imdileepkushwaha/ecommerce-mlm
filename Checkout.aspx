<%@ Page Title="Checkout" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true"
    CodeFile="Checkout.aspx.cs" Inherits="ecommerce_mlm.Checkout" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <asp:ScriptManager runat="server" ID="sm1" />

        <div class="cart-page-wrapper">
            <!-- Breadcrumb Top Bar -->
            <div class="dashboard-breadcrumb">
                <div class="container">
                    <div class="dashboard-breadcrumb-inner">
                        <div class="breadcrumb-left">
                            <h3>Secure Checkout</h3>
                        </div>
                        <div class="breadcrumb-right">
                            <a href="index.aspx"><i class="fas fa-home"></i></a>
                            <span> / Checkout</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="container py-5">
                <asp:UpdatePanel ID="upCheckout" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:HiddenField ID="hfCurrentStep" runat="server" Value="1" />
                        <asp:HiddenField ID="hfSelectedAddressId" runat="server" Value="" />
                        <asp:HiddenField ID="hfSelectedPayment" runat="server" Value="COD" />
                        <asp:HiddenField ID="hfShippingFee" runat="server" Value="" />
                        <asp:HiddenField ID="hfAppliedCouponCode" runat="server" Value="" />
                        <asp:HiddenField ID="hfCouponDiscountAmount" runat="server" Value="0" />
                        <asp:HiddenField ID="hfWalletBalance" runat="server" Value="0" />

                        <div class="cart-grid">
                            <!-- LEFT SECTION: STEPS -->
                            <div class="cart-items-section">
                                <!-- Tracker -->
                                <div class="timeline-tracker">
                                    <div class="timeline-line-container">
                                        <div class="timeline-baseline"></div>
                                        <div class="timeline-progress" id="timelineProgress"></div>
                                    </div>
                                    <div class="timeline-step active" id="track-step-1">
                                        1
                                        <div class="timeline-label">Delivery Address</div>
                                    </div>
                                    <div class="timeline-step" id="track-step-2">
                                        2
                                        <div class="timeline-label">Payment Method</div>
                                    </div>
                                    <div class="timeline-step" id="track-step-3">
                                        3
                                        <div class="timeline-label">Review & Confirm</div>
                                    </div>
                                </div>

                                <!-- STEP 1: ADDRESS -->
                                <div class="step-panel active" id="panel-step-1">
                                    <div class="step-title co-step-title-flex">
                                        <span><i class="fas fa-map-marker-alt co-text-orange"></i> Select Delivery
                                            Address</span>
                                        <asp:LinkButton ID="btnAddAddress" runat="server" CssClass="co-btn-add-address"
                                            OnClick="btnAddAddress_Click">
                                            <i class="fas fa-plus-circle"></i> Add Address
                                        </asp:LinkButton>
                                    </div>

                                    <div class="address-grid">
                                        <asp:Repeater ID="rptAddresses" runat="server"
                                            OnItemCommand="rptAddresses_ItemCommand">
                                            <ItemTemplate>
                                                <div class='address-card <%# Eval("Id").ToString() == hfSelectedAddressId.Value ? "selected" : "" %>'
                                                    onclick="selectAddress('<%# Eval(" Id") %>')">
                                                    <i class="fas fa-check-circle check-icon"></i>
                                                    <span class="address-tag">
                                                        <%# Eval("Tag") %>
                                                    </span>

                                                    <!-- Default Badge -->
                                                    <%# Convert.ToBoolean(Eval("IsDefault"))
                                                        ? "<span class='address-badge-default'>Default</span>" : "" %>

                                                        <div class="address-name">
                                                            <%# Eval("FullName") %>
                                                        </div>
                                                        <div class="address-text">
                                                            <%# Eval("StreetAddress") %>, <%# Eval("City") %>, <%#
                                                                        Eval("State") %> - <%# Eval("ZipCode") %>
                                                        </div>
                                                        <div class="address-phone">Phone: <%# Eval("PhoneNumber") %>
                                                        </div>
                                                        <div class="address-actions" onclick="event.stopPropagation();">
                                                            <asp:LinkButton ID="btnEdit" runat="server"
                                                                CommandName="EditAddress"
                                                                CommandArgument='<%# Eval("Id") %>'
                                                                CssClass="address-btn-edit"><i
                                                                    class="far fa-edit mr-5"></i>Edit
                                                            </asp:LinkButton>
                                                            <asp:LinkButton ID="btnSetDefault" runat="server"
                                                                CommandName="SetDefault"
                                                                CommandArgument='<%# Eval("Id") %>'
                                                                Visible='<%# !Convert.ToBoolean(Eval("IsDefault")) %>'
                                                                CssClass="address-btn-default"><i
                                                                    class="far fa-check-circle mr-5"></i>Set default
                                                            </asp:LinkButton>
                                                            <asp:LinkButton ID="btnRemove" runat="server"
                                                                CommandName="RemoveAddress"
                                                                CommandArgument='<%# Eval("Id") %>'
                                                                OnClientClick="return confirm('Are you sure you want to remove this address?');"
                                                                CssClass="address-btn-delete"><i
                                                                    class="far fa-trash-alt mr-5"></i>Delete
                                                            </asp:LinkButton>
                                                        </div>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>

                                <!-- STEP 2: PAYMENT -->
                                <div class="step-panel" id="panel-step-2">
                                    <div class="step-title"><span><i class="fas fa-credit-card co-text-cyan"></i>
                                            Payment Method</span></div>
                                    <div class="payment-options-row">
                                        <div class="payment-opt-card" id="pay-co-cod" onclick="selectPayment('COD')">
                                            <div class="pay-radio-circle"></div>
                                            <div class="pay-method-icon ico-cash"><i
                                                    class="fas fa-money-bill-wave-alt"></i></div>
                                            <div class="pay-method-info">
                                                <h4>Cash on Delivery</h4>
                                                <p>Pay when delivered</p>
                                            </div>
                                        </div>

                                        <div class="payment-opt-card" id="pay-co-online"
                                            onclick="selectPayment('Online')">
                                            <div class="pay-radio-circle"></div>
                                            <div class="pay-method-icon ico-online"><i class="fas fa-globe"></i></div>
                                            <div class="pay-method-info">
                                                <h4>Online Payment</h4>
                                                <p>UPI / Cards / Netbanking</p>
                                            </div>
                                        </div>

                                        <div class="payment-opt-card" id="pay-co-wallet"
                                            onclick="selectPayment('Wallet')">
                                            <div class="pay-radio-circle"></div>
                                            <div class="pay-method-icon ico-wallet"><i class="fas fa-wallet"></i></div>
                                            <div class="pay-method-info">
                                                <h4>Pay via Wallet</h4>
                                                <p>Instant discount & cashback</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="payment-instruction-box" id="payment-instruction-container">
                                        💵 <span class="ml-8">Cash on Delivery — Keep exact change ready.</span>
                                    </div>
                                </div>

                                <!-- STEP 3: REVIEW -->
                                <div class="step-panel" id="panel-step-3">
                                    <div class="step-title"><i class="fas fa-clipboard-check co-text-blue"></i> Review
                                        Your Order</div>

                                    <div class="review-box">
                                        <div class="review-box-title">Delivery Details <a href="javascript:void(0)"
                                                onclick="goToStep(1)">Change</a>
                                        </div>
                                        <div class="review-data" id="review-address-data">
                                            <!-- Injected via JS or CodeBehind -->
                                            <asp:Literal ID="litReviewAddress" runat="server"></asp:Literal>
                                        </div>
                                        <div class="mt-3 co-est-box">
                                            <i class="fas fa-truck"></i> Estimated Delivery: <span
                                                id="js-checkout-est-delivery">
                                                <asp:Literal ID="litEstDate" runat="server"></asp:Literal>
                                            </span>
                                        </div>
                                    </div>

                                    <div class="review-box">
                                        <div class="review-box-title">Payment Method <a href="javascript:void(0)"
                                                onclick="goToStep(2)">Change</a>
                                        </div>
                                        <div class="review-data" id="review-payment-data">
                                            Pending Selection
                                        </div>
                                    </div>
                                </div>

                                <!-- Navigation -->
                                <div class="step-nav co-step-nav-footer">
                                    <button type="button" class="co-btn-back" id="btnPrev" onclick="prevStep()"
                                        style="display:none;"><i class="fas fa-arrow-left mr-5"></i> Back</button>

                                    <button type="button" class="co-btn-orange-grad co-btn-next-step" id="btnNext"
                                        onclick="nextStep()">Continue to Payment</button>

                                    <asp:Button ID="btnPlaceOrderLeft" runat="server"
                                        CssClass="co-btn-orange-grad co-btn-next-step" Text="Place Order"
                                        Style="display:none;" OnClick="btnPlaceOrder_Click"
                                        OnClientClick="this.value='Processing...'; this.style.pointerEvents='none';" />
                                </div>
                            </div>

                            <!-- RIGHT SECTION: ORDER SUMMARY -->
                            <div class="cart-summary-section">
                                <div class="summary-sticky-card">
                                    <!-- Title with thick orange left bar -->
                                    <h3 class="summary-title">Order Summary</h3>

                                    <!-- Apply Coupon Box -->
                                    <div class="coupon-block">
                                        <div class="coupon-label">
                                            <i class="fas fa-tag" style="color:#f59e0b;"></i> Apply Coupon
                                        </div>
                                        <div class="coupon-input-group">
                                            <asp:TextBox ID="txtCouponCode" runat="server"
                                                CssClass="form-control coupon-input" placeholder="Enter code"
                                                style="text-transform:uppercase;"></asp:TextBox>
                                            <asp:Button ID="btnApplyCoupon" runat="server" Text="Apply"
                                                CssClass="btn btn-dark btn-coupon-apply" OnClick="btnApplyCoupon_Click"
                                                CausesValidation="false" />
                                        </div>
                                        <div class="applied-coupon-tags"
                                            style="display: flex; flex-direction: column; gap: 4px; margin-top: 6px;">
                                            <asp:Label ID="lblCouponMsg" runat="server" Font-Size="11px"
                                                Font-Weight="700" Visible="false"></asp:Label><asp:Panel ID="pnlActiveCoupon" runat="server" Visible="false"></asp:Panel>
                                            
                                        </div>
                                    </div>

                                    <!-- Free Delivery Dynamic Banner -->
                                    <div class="co-speed-free" id="divFreePromoBanner">
                                        <div class="text-wrap">
                                            <div class="desc" id="js-checkout-promo-text">🎉 FREE delivery on orders above ₹<%=
                                                    string.Format("{0:N0}", Convert.ToDecimal(ConfigMinFreeShipping)) %>
                                                    !</div>
                                        </div>
                                    </div>

                                    <!-- Delivery Speed -->
                                    <div class="delivery-speed-block mt-4">
                                        <div class="section-mini-label">
                                            <i class="fas fa-shipping-fast"></i> Delivery Speed
                                        </div>

                                        <!-- Standard -->
                                        <div class="speed-option js-co-speed active"
                                            data-fee="<%= ConfigShippingFee %>" data-name="Standard" data-is-standard="true"
                                            data-min-days="3" data-max-days="5">
                                            <div class="speed-name">Standard (3-5 days)</div>
                                            <div class="speed-cost js-co-speed-cost">₹ <%= ConfigShippingFee %></div>
                                        </div>
                                        <!-- Express -->
                                        <div class="speed-option js-co-speed" data-fee="89" data-name="Express"
                                            data-is-standard="false" data-min-days="1" data-max-days="2">
                                            <div class="speed-name">Express (1-2 days)</div>
                                            <div class="speed-cost">₹ 89</div>
                                        </div>
                                        <!-- Same Day -->
                                        <div class="speed-option js-co-speed" data-fee="149" data-name="Same Day"
                                            data-is-standard="false" data-min-days="0" data-max-days="0">
                                            <div class="speed-name">Same Day</div>
                                            <div class="speed-cost">₹ 149</div>
                                        </div>
                                    </div>

                                    <!-- Billing Details -->
                                    <div class="billing-breakdown mt-4">
                                        <div class="billing-row">
                                            <span>Subtotal ( <span id="js-count-span">
                                                    <asp:Literal ID="litTotalItems" runat="server"></asp:Literal>
                                                </span> items)</span>
                                            <span class="bill-val">₹ <span id="js-subtotal-val">
                                                    <asp:Literal ID="litSubtotal" runat="server"></asp:Literal>
                                                </span></span>
                                        </div>
                                        <div class="billing-row">
                                            <span>Delivery Charges</span>
                                            <span id="js-del-cost-checkout" class="bill-val">
                                                <asp:Literal ID="litShippingVisual" runat="server"></asp:Literal>
                                            </span>
                                        </div>
                                        <div class="billing-row">
                                            <span>Platform Fee</span>
                                            <span class="bill-val">₹ <span id="js-platform-cost-checkout">
                                                    <%= ConfigPlatformFee %>
                                                </span></span>
                                        </div>
                                                <asp:Panel ID="pnlDiscountRow" runat="server" CssClass="billing-row" Visible="false" style="color:#10b981; font-weight:700;">
                                            <span style="display:flex; align-items:center; gap:8px;">
                                                <span>Coupon (<span id="js-active-coupon-code" style="color:#f59e0b; text-transform:uppercase;"><asp:Literal ID="litActiveCode" runat="server"></asp:Literal></span>)</span>
                                                <asp:LinkButton ID="btnRemoveCoupon" runat="server" OnClick="btnRemoveCoupon_Click" ToolTip="Remove Coupon" style="color:#ef4444; font-size:0.85rem; cursor:pointer;" CausesValidation="false">
                                                    <i class="fas fa-times-circle"></i>
                                                </asp:LinkButton>
                                            </span>
                                            <span class="bill-val" style="color:#10b981; font-weight:700;">- ₹ <span id="js-coupon-discount-val"><asp:Literal ID="litDiscountAmt" runat="server">0</asp:Literal></span></span>
                                        </asp:Panel>
                                    </div>
                                    <hr class="billing-separator" />
                                    <div class="billing-row total-row">
                                        <strong>Total Amount</strong>
                                        <strong class="total-val">₹ <span id="js-checkout-grand-total">
                                                <asp:Literal ID="litGrandTotal" runat="server"></asp:Literal>
                                            </span></strong>
                                    </div>

                                    <!-- Vibrant Step Action Buttons with orange gradient matching image -->
                                    <button type="button" class="btn btn-orange-checkout" id="btnSummaryNext"
                                        onclick="nextStep()">Continue to Payment</button>
                                    <asp:Button ID="btnPlaceOrder" runat="server" CssClass="btn btn-orange-checkout"
                                        Text="Place Order" Style="display:none;" OnClick="btnPlaceOrder_Click"
                                        OnClientClick="this.value='Processing...'; this.style.pointerEvents='none';" />

                                    <div class="trust-badge text-center mt-3">
                                        <i class="fas fa-lock"></i> Secured by 256-bit SSL encryption
                                    </div>
                                </div>
                            </div>
                        </div>

                        <script>
                            // Expose literal info to JS safely
                            var reviewAddressHtml = `<%= litReviewAddress.Text.Replace("`", "\\`") %>`;
                        </script>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>

        <!-- ORDER SUCCESS MODAL -->
        <div class="custom-modal-overlay" id="orderSuccessModal">
            <div class="custom-modal co-success-modal">
                <div class="success-icon-box">
                    <i class="fas fa-check"></i>
                </div>
                <h2 class="co-success-title">Order Placed Successfully!</h2>
                <p class="co-success-subtitle">Thank you for your purchase! Your order details have been processed and
                    will be delivered soon.</p>

                <div class="co-success-actions">
                    <a href="UserOrders.aspx" class="co-success-btn-primary"><i class="fas fa-box-open mr-5"></i> View
                        My Orders</a>
                    <a href="index.aspx" class="co-success-btn-secondary"><i class="fas fa-shopping-bag mr-5"></i>
                        Continue Shopping</a>
                </div>
            </div>
        </div>

        <!-- CUSTOM ADDRESS MODAL -->
        <div class="custom-modal-overlay" id="addressModalOverlay">
            <div class="custom-modal">
                <asp:UpdatePanel ID="upModal" runat="server">
                    <ContentTemplate>
                        <div class="custom-modal-header">
                            <h5>
                                <asp:Literal ID="litModalTitle" runat="server" Text="Add New Address"></asp:Literal>
                            </h5>
                            <button type="button" class="custom-modal-close"
                                onclick="closeAddressModal()">&times;</button>
                        </div>
                        <div class="custom-modal-body">
                            <asp:HiddenField ID="hfEditAddressId" runat="server" Value="" />

                            <div class="mb-3">
                                <label class="form-label text-muted co-modal-lbl-styled">Full Name</label>
                                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control"
                                    placeholder="John Doe"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label text-muted co-modal-lbl-styled">Phone Number</label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control"
                                    placeholder="10-digit mobile number"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label text-muted co-modal-lbl-styled">Street Address / Area</label>
                                <asp:TextBox ID="txtStreet" runat="server" CssClass="form-control" TextMode="MultiLine"
                                    Rows="2" placeholder="House/Flat No., Street, Landmark"></asp:TextBox>
                            </div>
                            <div class="co-modal-flex-row">
                                <div class="flex-1">
                                    <label class="form-label text-muted co-modal-lbl-styled">City</label>
                                    <asp:TextBox ID="txtCity" runat="server" CssClass="form-control" placeholder="City">
                                    </asp:TextBox>
                                </div>
                                <div class="flex-1">
                                    <label class="form-label text-muted co-modal-lbl-styled">State</label>
                                    <asp:TextBox ID="txtState" runat="server" CssClass="form-control"
                                        placeholder="State"></asp:TextBox>
                                </div>
                            </div>
                            <div class="co-modal-flex-row">
                                <div class="flex-1">
                                    <label class="form-label text-muted co-modal-lbl-styled">Pincode / ZipCode</label>
                                    <asp:TextBox ID="txtZip" runat="server" CssClass="form-control"
                                        placeholder="ZipCode"></asp:TextBox>
                                </div>
                                <div class="flex-1">
                                    <label class="form-label text-muted co-modal-lbl-styled">Tag</label>
                                    <asp:DropDownList ID="ddlTag" runat="server" CssClass="form-select">
                                        <asp:ListItem Text="Home" Value="Home"></asp:ListItem>
                                        <asp:ListItem Text="Work" Value="Work"></asp:ListItem>
                                        <asp:ListItem Text="Other" Value="Other"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="mb-3 co-modal-chk-wrap">
                                <asp:CheckBox ID="chkDefault" runat="server" />
                                <label for="<%= chkDefault.ClientID %>" class="co-modal-chk-lbl">Make this my default
                                    address</label>
                            </div>

                            <asp:Label ID="lblModalError" runat="server" ForeColor="Red" Font-Size="13px"
                                Visible="false"></asp:Label>
                        </div>
                        <div class="custom-modal-footer co-modal-ftr">
                            <button type="button" class="btn btn-light co-modal-btn-cancel"
                                onclick="closeAddressModal()">Cancel</button>
                            <asp:Button ID="btnSaveAddress" runat="server" Text="Save Address"
                                CssClass="btn btn-primary co-modal-btn-save" OnClick="btnSaveAddress_Click" />
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>

        <!-- UI Interaction Scripts -->
        <script>
            let currentStep = 1;

            function updateUI() {
                // Hide all panels
                document.querySelectorAll('.step-panel').forEach(p => p.classList.remove('active'));
                // Show target panel
                document.getElementById('panel-step-' + currentStep).classList.add('active');

                // Update tracker
                for (let i = 1; i <= 3; i++) {
                    let track = document.getElementById('track-step-' + i);
                    if (track) {
                        track.classList.remove('active', 'completed');
                        if (i < currentStep) track.classList.add('completed');
                        if (i === currentStep) track.classList.add('active');
                    }
                }

                // Update Progress Bar
                const pBar = document.getElementById('timelineProgress');
                if (pBar) {
                    if (currentStep === 1) pBar.style.width = '0%';
                    if (currentStep === 2) pBar.style.width = '50%';
                    if (currentStep === 3) pBar.style.width = '100%';
                }

                // Update Nav Buttons
                const btnPrev = document.getElementById('btnPrev');
                const btnNext = document.getElementById('btnNext');
                const btnPlaceOrderLeft = document.getElementById('<%= btnPlaceOrderLeft.ClientID %>');
                const btnSummaryNext = document.getElementById('btnSummaryNext');
                const btnPlaceOrder = document.getElementById('<%= btnPlaceOrder.ClientID %>');

                if (btnPrev) btnPrev.style.display = currentStep > 1 ? 'block' : 'none';

                if (currentStep === 1) {
                    if (btnSummaryNext) {
                        btnSummaryNext.style.display = 'block';
                        btnSummaryNext.innerText = 'Continue to Payment';
                    }
                    if (btnNext) {
                        btnNext.style.display = 'block';
                        btnNext.innerText = 'Continue to Payment';
                    }
                    if (btnPlaceOrder) btnPlaceOrder.style.display = 'none';
                    if (btnPlaceOrderLeft) btnPlaceOrderLeft.style.display = 'none';
                } else if (currentStep === 2) {
                    if (btnSummaryNext) {
                        btnSummaryNext.style.display = 'block';
                        btnSummaryNext.innerText = 'Review & Confirm';
                    }
                    if (btnNext) {
                        btnNext.style.display = 'block';
                        btnNext.innerText = 'Review & Confirm';
                    }
                    if (btnPlaceOrder) btnPlaceOrder.style.display = 'none';
                    if (btnPlaceOrderLeft) btnPlaceOrderLeft.style.display = 'none';
                } else if (currentStep === 3) {
                    if (btnSummaryNext) btnSummaryNext.style.display = 'none';
                    if (btnNext) btnNext.style.display = 'none';
                    if (btnPlaceOrder) btnPlaceOrder.style.display = 'block';
                    if (btnPlaceOrderLeft) btnPlaceOrderLeft.style.display = 'block';
                    populateReviewData();
                }

                // Sync with hidden field
                const hfStep = document.getElementById('<%= hfCurrentStep.ClientID %>');
                if (hfStep) hfStep.value = currentStep;
            }

            function nextStep() {
                if (currentStep === 1) {
                    if (!document.getElementById('<%= hfSelectedAddressId.ClientID %>').value) {
                        if (typeof showToast === 'function') showToast('Please select a delivery address', 'warning');
                        else alert('Please select a delivery address');
                        return;
                    }
                }
                if (currentStep === 2) {
                    const payMethod = document.getElementById('<%= hfSelectedPayment.ClientID %>').value;
                    if (!payMethod) {
                        if (typeof showToast === 'function') showToast('Please select a payment method', 'warning');
                        else alert('Please select a payment method');
                        return;
                    }
                    if (payMethod === 'Wallet') {
                        const balance = getWalletBalance();
                        const total = getGrandTotal();
                        if (balance < total) {
                            if (typeof showToast === 'function') {
                                showToast('Insufficient Wallet Balance. Please add money or choose another payment method.', 'warning');
                            } else {
                                alert('Insufficient Wallet Balance. Please add money or choose another payment method.');
                            }
                            return;
                        }
                    }
                }

                if (currentStep < 3) {
                    currentStep++;
                    updateUI();
                }
            }

            function prevStep() {
                if (currentStep > 1) {
                    currentStep--;
                    updateUI();
                }
            }

            function goToStep(step) {
                currentStep = step;
                updateUI();
            }

            function selectAddress(id) {
                document.getElementById('<%= hfSelectedAddressId.ClientID %>').value = id;
                document.querySelectorAll('.address-card').forEach(c => c.classList.remove('selected'));
                event.currentTarget.classList.add('selected');

                const card = event.currentTarget;
                const name = card.querySelector('.address-name').innerText;
                const text = card.querySelector('.address-text').innerHTML;
                const phone = card.querySelector('.address-phone').innerText;
                reviewAddressHtml = `<strong>${name}</strong><br/>${text}<br/>${phone}`;
            }

            function getWalletBalance() {
                const el = document.getElementById('<%= hfWalletBalance.ClientID %>');
                return el ? parseFloat(el.value) || 0 : 0;
            }

            function getGrandTotal() {
                const subtotal = getBaseSubtotal();
                const cfgMinFree = parseFloat('<%= ConfigMinFreeShipping %>') || 1000;
                const cfgPlatFee = parseFloat('<%= ConfigPlatformFee %>') || 5;
                const activeSpeedNode = document.querySelector('.speed-option.js-co-speed.active');
                
                let isEligible = subtotal >= cfgMinFree;
                let baseFee = 0;
                if (activeSpeedNode) {
                    baseFee = parseFloat(activeSpeedNode.getAttribute('data-fee')) || 0;
                    const isStandard = activeSpeedNode.getAttribute('data-is-standard') === 'true';
                    if (isStandard && isEligible) {
                        baseFee = 0;
                    }
                }
                
                const hfDisc = document.getElementById('<%= hfCouponDiscountAmount.ClientID %>');
                const discount = hfDisc ? parseFloat(hfDisc.value) || 0 : 0;
                return Math.max(0, subtotal + baseFee + cfgPlatFee - discount);
            }

            function selectPayment(method) {
                document.getElementById('<%= hfSelectedPayment.ClientID %>').value = method;
                document.querySelectorAll('.payment-opt-card').forEach(c => {
                    c.classList.remove('selected');
                });

                let targetCard;
                let instructionHtml = '';
                if (method === 'COD') {
                    targetCard = document.getElementById('pay-co-cod');
                    instructionHtml = '💵 <span class="ml-8">Cash on Delivery — Keep exact change ready.</span>';
                }
                if (method === 'Online') {
                    targetCard = document.getElementById('pay-co-online');
                    instructionHtml = '🌐 <span class="ml-8">Online Payment — Fast, safe, and 100% secure.</span>';
                }
                if (method === 'Wallet') {
                    targetCard = document.getElementById('pay-co-wallet');
                    
                    const balance = getWalletBalance();
                    const total = getGrandTotal();
                    const isSufficient = balance >= total;
                    
                    if (isSufficient) {
                        instructionHtml = `
                            <div class="wallet-instruction-flex" style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
                                <div class="wallet-instruction-left" style="display: flex; align-items: center; gap: 8px;">
                                    <span style="font-size: 20px;">👛</span>
                                    <div class="wallet-msg-container">
                                        <div class="wallet-title" style="font-weight: 700; color: #1e293b;">Wallet Payment</div>
                                        <div class="wallet-desc" style="font-size: 13px; font-weight: 600; color: #10b981;"><i class="fas fa-check-circle"></i> Sufficient Balance — Seamless wallet payout active.</div>
                                    </div>
                                </div>
                                <div class="wallet-instruction-right" style="text-align: right; display: flex; flex-direction: column; justify-content: center;">
                                    <div class="wallet-bal-lbl" style="font-size: 10px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.5px;">Your Balance</div>
                                    <div class="wallet-bal-val" style="font-size: 16px; font-weight: 800; color: #10b981;">₹ ${balance.toFixed(2)}</div>
                                </div>
                            </div>`;
                    } else {
                        const shortAmt = total - balance;
                        instructionHtml = `
                            <div class="wallet-instruction-flex" style="display: flex; justify-content: space-between; align-items: center; width: 100%; flex-wrap: wrap; gap: 12px;">
                                <div class="wallet-instruction-left" style="display: flex; align-items: center; gap: 8px; flex: 1; min-width: 250px;">
                                    <span style="font-size: 20px;">👛</span>
                                    <div class="wallet-msg-container">
                                        <div class="wallet-title" style="font-weight: 700; color: #1e293b;">Wallet Payment</div>
                                        <div class="wallet-desc" style="font-size: 13px; font-weight: 600; color: #ef4444;"><i class="fas fa-exclamation-circle"></i> Short by ₹ ${shortAmt.toFixed(2)} — Add funds to checkout.</div>
                                    </div>
                                </div>
                                <div class="wallet-instruction-right" style="display: flex; align-items: center; gap: 14px; text-align: right;">
                                    <div>
                                        <div class="wallet-bal-lbl" style="font-size: 10px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.5px;">Your Balance</div>
                                        <div class="wallet-bal-val" style="font-size: 16px; font-weight: 800; color: #ef4444;">₹ ${balance.toFixed(2)}</div>
                                    </div>
                                    <a href="userIncome.aspx" class="btn-add-wallet-funds" style="display: inline-flex; align-items: center; gap: 6px; padding: 8px 14px; background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%); color: #ffffff !important; font-size: 11px; font-weight: 700; border-radius: 8px; box-shadow: 0 4px 10px rgba(124, 58, 237, 0.2); transition: all 0.2s; white-space: nowrap; text-transform: uppercase; text-decoration: none;">Add Money <i class="fas fa-plus-circle"></i></a>
                                </div>
                            </div>`;
                    }
                }

                if (targetCard) {
                    targetCard.classList.add('selected');
                }

                const instBox = document.getElementById('payment-instruction-container');
                if (instBox) {
                    instBox.style.opacity = '0';
                    setTimeout(() => {
                        instBox.innerHTML = instructionHtml;
                        instBox.style.opacity = '1';
                    }, 100);
                }
            }

            function populateReviewData() {
                const addrDiv = document.getElementById('review-address-data');
                if (addrDiv) addrDiv.innerHTML = reviewAddressHtml;

                const method = document.getElementById('<%= hfSelectedPayment.ClientID %>').value;
                let paymentText = '';
                if (method === 'COD') {
                    paymentText = '<i class="fas fa-money-bill-wave co-text-green"></i> Cash on Delivery (COD)';
                } else if (method === 'Online') {
                    paymentText = '<i class="fas fa-laptop-code co-text-green"></i> Secure Online Payment';
                } else if (method === 'Wallet') {
                    paymentText = '<i class="fas fa-wallet co-text-green"></i> Wallet Balance';
                }

                const payDiv = document.getElementById('review-payment-data');
                if (payDiv) payDiv.innerHTML = paymentText;
            }

            // --- DYNAMIC SUMMARY CALCULATION & SHIPPING LOGIC ---
            function getBaseSubtotal() {
                const el = document.getElementById('js-subtotal-val');
                if (!el) return 0;
                const clean = el.innerText.replace(/[^0-9.]/g, '');
                return parseFloat(clean) || 0;
            }

            function updateCheckoutSummary() {
                try {
                    const subtotal = getBaseSubtotal();
                    const cfgMinFree = parseFloat('<%= ConfigMinFreeShipping %>') || 1000;
                    const cfgPlatFee = parseFloat('<%= ConfigPlatformFee %>') || 5;

                    const banner = document.getElementById('divFreePromoBanner');
                    const promoText = document.getElementById('js-checkout-promo-text');
                    const activeSpeedNode = document.querySelector('.speed-option.js-co-speed.active');

                    let isEligible = subtotal >= cfgMinFree;

                    if (promoText) {
                        if (isEligible) {
                            promoText.innerHTML = '🎉 <span class="co-text-green">Awesome! Your shipping is FREE on Standard option.</span>';
                            if (banner) {
                                banner.classList.remove('co-banner-warning');
                                banner.classList.add('co-banner-success');
                            }
                        } else {
                            let diff = cfgMinFree - subtotal;
                            promoText.innerHTML = 'Add <b>₹ ' + diff.toLocaleString('en-IN') + '</b> more for FREE Delivery!';
                            if (banner) {
                                banner.classList.remove('co-banner-success');
                                banner.classList.add('co-banner-warning');
                            }
                        }
                    }

                    const stdOption = document.querySelector('.js-co-speed[data-is-standard="true"]');
                    if (stdOption) {
                        const costNode = stdOption.querySelector('.js-co-speed-cost');
                        if (costNode) {
                            costNode.innerText = isEligible ? 'FREE' : '₹ <%= ConfigShippingFee %>';
                        }
                    }

                    let baseFee = 0;
                    if (activeSpeedNode) {
                        baseFee = parseFloat(activeSpeedNode.getAttribute('data-fee')) || 0;
                        const isStandard = activeSpeedNode.getAttribute('data-is-standard') === 'true';
                        if (isStandard && isEligible) {
                            baseFee = 0;
                        }

                        // Update dynamic estimated delivery range text on Review Step
                        const minD = activeSpeedNode.hasAttribute('data-min-days') ? parseInt(activeSpeedNode.getAttribute('data-min-days')) : 3;
                        const maxD = activeSpeedNode.hasAttribute('data-max-days') ? parseInt(activeSpeedNode.getAttribute('data-max-days')) : 5;
                        const estSpan = document.getElementById('js-checkout-est-delivery');
                        if (estSpan && typeof window.getFormattedDeliveryRange === 'function') {
                            estSpan.innerText = window.getFormattedDeliveryRange(minD, maxD, true); // true = include Year
                        }
                        // Sync fee to server hidden field
                        const hfShip = document.getElementById('<%= hfShippingFee.ClientID %>');
                        if (hfShip) { hfShip.value = baseFee; }
                    }

                    const delCell = document.getElementById('js-del-cost-checkout');
                    if (delCell) {
                        if (baseFee === 0) {
                            delCell.innerHTML = '<span class="co-free-badge">FREE</span>';
                        } else {
                            delCell.innerHTML = '₹ ' + baseFee;
                        }
                    }

                    const hfDisc = document.getElementById('<%= hfCouponDiscountAmount.ClientID %>');
                    const discount = hfDisc ? parseFloat(hfDisc.value) || 0 : 0;
                    const grandTotal = Math.max(0, subtotal + baseFee + cfgPlatFee - discount);
                    const totalEl = document.getElementById('js-checkout-grand-total');
                    if (totalEl) {
                        totalEl.innerText = grandTotal.toLocaleString('en-IN');
                    }

                    // Refresh payment instructions if Wallet is active to recalculate sufficiency
                    const hfPay = document.getElementById('<%= hfSelectedPayment.ClientID %>');
                    if (hfPay && hfPay.value === 'Wallet') {
                        selectPayment('Wallet');
                    }
                } catch (e) {
                    console.error('Checkout summary update error:', e);
                }
            }

            function setupCheckoutSpeedOptions() {
                document.querySelectorAll('.js-co-speed').forEach(opt => {
                    opt.onclick = function () {
                        document.querySelectorAll('.js-co-speed').forEach(o => {
                            o.classList.remove('active');
                        });
                        this.classList.add('active');
                        updateCheckoutSummary();
                    };
                });
            }

            // Custom Modal Logic
            function openSuccessModal() {
                document.getElementById('orderSuccessModal').classList.add('active');
                document.body.style.overflow = 'hidden';
            }

            function openAddressModal() {
                document.getElementById('addressModalOverlay').classList.add('active');
                document.body.style.overflow = 'hidden'; // prevent background scrolling
            }

            function closeAddressModal() {
                document.getElementById('addressModalOverlay').classList.remove('active');
                document.body.style.overflow = '';
            }

            // Re-attach UI state after ASP.NET UpdatePanel Postbacks
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(function () {
                const hfStep = document.getElementById('<%= hfCurrentStep.ClientID %>');
                const savedStep = hfStep ? (parseInt(hfStep.value) || 1) : 1;
                currentStep = savedStep;
                updateUI();

                const hfPay = document.getElementById('<%= hfSelectedPayment.ClientID %>');
                const method = hfPay ? hfPay.value : null;
                if (method) selectPayment(method);

                // Rebind speed events and update summary recalculation
                setupCheckoutSpeedOptions();
                updateCheckoutSummary();
            });

            // Initialize
            document.addEventListener('DOMContentLoaded', () => {
                updateUI();
                setupCheckoutSpeedOptions();
                updateCheckoutSummary();

                // Select default payment method on load
                const hfPay = document.getElementById('<%= hfSelectedPayment.ClientID %>');
                const method = hfPay && hfPay.value ? hfPay.value : 'COD';
                selectPayment(method);
            });
        </script>
    </asp:Content>