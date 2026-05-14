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
                        <asp:HiddenField ID="hfSelectedPayment" runat="server" Value="" />
                        <asp:HiddenField ID="hfShippingFee" runat="server" Value="" />

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
                                        <span><i class="fas fa-map-marker-alt co-text-orange"></i> Select Delivery Address</span>
                                        <asp:LinkButton ID="btnAddAddress" runat="server" CssClass="co-btn-add-address" OnClick="btnAddAddress_Click">
                                            <i class="fas fa-plus-circle"></i> Add Address
                                        </asp:LinkButton>
                                    </div>

                                    <div class="address-grid">
                                        <asp:Repeater ID="rptAddresses" runat="server"
                                            OnItemCommand="rptAddresses_ItemCommand">
                                            <ItemTemplate>
                                                <div class='address-card <%# Eval("Id").ToString() == hfSelectedAddressId.Value ? "selected" : "" %>'
                                                    onclick="selectAddress('<%# Eval("Id") %>')">
                                                        <i class="fas fa-check-circle check-icon"></i>
                                                        <span class="address-tag">
                                                            <%# Eval("Tag") %>
                                                        </span>

                                                        <!-- Default Badge -->
                                                        <%# Convert.ToBoolean(Eval("IsDefault"))
                                                            ? "<span class='address-badge-default'>Default</span>" : ""
                                                            %>

                                                            <div class="address-name">
                                                                <%# Eval("FullName") %>
                                                            </div>
                                                            <div class="address-text">
                                                                <%# Eval("StreetAddress") %>, <%# Eval("City") %>, <%#
                                                                            Eval("State") %> - <%# Eval("ZipCode") %>
                                                            </div>
                                                            <div class="address-phone">Phone: <%# Eval("PhoneNumber") %>
                                                            </div>
                                                            <div class="address-actions"
                                                                onclick="event.stopPropagation();">
                                                                <asp:LinkButton ID="btnEdit" runat="server"
                                                                    CommandName="EditAddress"
                                                                    CommandArgument='<%# Eval("Id") %>'
                                                                    CssClass="address-btn-edit"><i class="far fa-edit mr-5"></i>Edit
                                                                </asp:LinkButton>
                                                                <asp:LinkButton ID="btnSetDefault" runat="server"
                                                                    CommandName="SetDefault"
                                                                    CommandArgument='<%# Eval("Id") %>'
                                                                    Visible='<%# !Convert.ToBoolean(Eval("IsDefault")) %>'
                                                                    CssClass="address-btn-default"><i class="far fa-check-circle mr-5"></i>Set default
                                                                </asp:LinkButton>
                                                                <asp:LinkButton ID="btnRemove" runat="server"
                                                                    CommandName="RemoveAddress"
                                                                    CommandArgument='<%# Eval("Id") %>'
                                                                    OnClientClick="return confirm('Are you sure you want to remove this address?');"
                                                                    CssClass="address-btn-delete"><i class="far fa-trash-alt mr-5"></i>Delete
                                                                </asp:LinkButton>
                                                            </div>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>

                                <!-- STEP 2: PAYMENT -->
                                <div class="step-panel" id="panel-step-2">
                                    <div class="step-title"><span><i class="fas fa-credit-card co-text-cyan"></i> Payment Method</span></div>
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
                                    </div>
                                    <div class="payment-instruction-box" id="payment-instruction-container">
                                        💵 <span class="ml-8">Cash on Delivery — Keep exact change ready.</span>
                                    </div>
                                </div>

                                <!-- STEP 3: REVIEW -->
                                <div class="step-panel" id="panel-step-3">
                                    <div class="step-title"><i class="fas fa-clipboard-check co-text-blue"></i> Review Your Order</div>

                                    <div class="review-box">
                                        <div class="review-box-title">Delivery Details <a href="javascript:void(0)" onclick="goToStep(1)">Change</a>
                                        </div>
                                        <div class="review-data" id="review-address-data">
                                            <!-- Injected via JS or CodeBehind -->
                                            <asp:Literal ID="litReviewAddress" runat="server"></asp:Literal>
                                        </div>
                                        <div class="mt-3 co-est-box">
                                            <i class="fas fa-truck"></i> Estimated Delivery: <span id="js-checkout-est-delivery"><asp:Literal ID="litEstDate" runat="server"></asp:Literal></span>
                                        </div>
                                    </div>

                                    <div class="review-box">
                                        <div class="review-box-title">Payment Method <a href="javascript:void(0)" onclick="goToStep(2)">Change</a>
                                        </div>
                                        <div class="review-data" id="review-payment-data">
                                            Pending Selection
                                        </div>
                                    </div>
                                </div>

                                <!-- Navigation -->
                                <div class="step-nav co-step-nav-footer">
                                    <button type="button" class="co-btn-back" id="btnPrev" onclick="prevStep()" style="display:none;"><i class="fas fa-arrow-left mr-5"></i> Back</button>

                                    <button type="button" class="co-btn-orange-grad co-btn-next-step" id="btnNext" onclick="nextStep()">Continue to Payment</button>

                                    <asp:Button ID="btnPlaceOrderLeft" runat="server" CssClass="co-btn-orange-grad co-btn-next-step" Text="Place Order"
                                        Style="display:none;"
                                        OnClick="btnPlaceOrder_Click"
                                        OnClientClick="this.value='Processing...'; this.style.pointerEvents='none';" />
                                </div>
                            </div>

                            <!-- RIGHT SECTION: ORDER SUMMARY -->
                            <div class="cart-summary-section">
                                <div class="summary-sticky-card co-summary-sticky">
                                    <!-- Title with thick orange left bar -->
                                    <h3 class="summary-title co-summary-title-styled">Order Summary</h3>

                                    <!-- Apply Coupon Box -->
                                    <div class="coupon-block co-coupon-block">
                                        <div class="coupon-label co-coupon-label-styled">
                                            <i class="fas fa-tag co-text-yellow"></i> Apply Coupon
                                        </div>
                                        <div class="coupon-input-group co-coupon-input-grp">
                                            <input type="text" placeholder="Enter code" class="form-control co-coupon-inp" />
                                            <button type="button" class="btn co-coupon-btn-apply">Apply</button>
                                        </div>
                                        <div class="applied-coupon-tags">
                                            <span class="coupon-tag co-coupon-badge">SAVE10</span>
                                        </div>
                                    </div>

                                    <!-- Free Delivery Dynamic Banner -->
                                    <div class="co-speed-free co-speed-banner co-banner-success" id="divFreePromoBanner">
                                        <span id="js-checkout-promo-text">🎉 FREE delivery on orders above ₹<%=
                                                string.Format("{0:N0}", Convert.ToDecimal(ConfigMinFreeShipping)) %> !</span>
                                    </div>

                                    <!-- Delivery Speed -->
                                    <div class="delivery-speed-block co-speed-block">
                                        <div class="section-mini-label co-speed-lbl">
                                            <i class="fas fa-shipping-fast"></i> Delivery Speed
                                        </div>

                                        <!-- Standard -->
                                        <div class="speed-option js-co-speed co-speed-opt-base active" data-fee="<%= ConfigShippingFee %>"
                                            data-is-standard="true" data-min-days="3" data-max-days="5">
                                            <span>Standard (3-5 days)</span>
                                            <span class="js-co-speed-cost">₹ <%= ConfigShippingFee %></span>
                                        </div>
                                        <!-- Express -->
                                        <div class="speed-option js-co-speed co-speed-opt-base" data-fee="89" data-is-standard="false"
                                            data-min-days="1" data-max-days="2">
                                            <span>Express (1-2 days)</span>
                                            <span>₹ 89</span>
                                        </div>
                                        <!-- Same Day -->
                                        <div class="speed-option js-co-speed co-speed-opt-base" data-fee="149" data-is-standard="false"
                                            data-min-days="0" data-max-days="0">
                                            <span>Same Day</span>
                                            <span>₹ 149</span>
                                        </div>
                                    </div>

                                    <!-- Billing Details -->
                                    <div class="billing-breakdown mt-4">
                                        <div class="billing-row co-billing-row-flex">
                                            <span>Subtotal ( <span id="js-count-span"><asp:Literal ID="litTotalItems" runat="server"></asp:Literal></span> items)</span>
                                            <span class="co-billing-val-bold">₹ <span id="js-subtotal-val"><asp:Literal ID="litSubtotal" runat="server"></asp:Literal></span></span>
                                        </div>
                                        <div class="billing-row co-billing-row-flex">
                                            <span>Delivery Charges</span>
                                            <span id="js-del-cost-checkout" class="co-billing-val-bold"><asp:Literal ID="litShippingVisual" runat="server"></asp:Literal></span>
                                        </div>
                                        <div class="billing-row co-billing-row-flex">
                                            <span>Platform Fee</span>
                                            <span class="co-billing-val-bold">₹ <span id="js-platform-cost-checkout"><%= ConfigPlatformFee %></span></span>
                                        </div>
                                    </div>
                                    <hr class="billing-separator co-billing-sep" />
                                    <div class="billing-row total-row co-billing-total-row">
                                        <strong class="co-billing-total-lbl">Total Amount</strong>
                                        <strong class="co-billing-total-val">₹ <span id="js-checkout-grand-total"><asp:Literal ID="litGrandTotal" runat="server"></asp:Literal></span></strong>
                                    </div>

                                    <!-- Vibrant Step Action Buttons with orange gradient matching image -->
                                    <button type="button" class="btn co-btn-orange-grad co-btn-checkout-final" id="btnSummaryNext" onclick="nextStep()">Continue to Payment</button>
                                    <asp:Button ID="btnPlaceOrder" runat="server" CssClass="btn co-btn-orange-grad co-btn-checkout-final" Text="Place Order"
                                        Style="display:none;"
                                        OnClick="btnPlaceOrder_Click"
                                        OnClientClick="this.value='Processing...'; this.style.pointerEvents='none';" />

                                    <div class="trust-badge text-center co-trust-badge">
                                        <i class="fas fa-lock co-text-yellow"></i> Secured by 256-bit SSL encryption
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
                <p class="co-success-subtitle">Thank you for your purchase! Your order details have been processed and will be delivered soon.</p>
                
                <div class="co-success-actions">
                    <a href="UserOrders.aspx" class="co-success-btn-primary"><i class="fas fa-box-open mr-5"></i> View My Orders</a>
                    <a href="index.aspx" class="co-success-btn-secondary"><i class="fas fa-shopping-bag mr-5"></i> Continue Shopping</a>
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
                                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="John Doe"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label text-muted co-modal-lbl-styled">Phone Number</label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="10-digit mobile number"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label text-muted co-modal-lbl-styled">Street Address / Area</label>
                                <asp:TextBox ID="txtStreet" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="House/Flat No., Street, Landmark"></asp:TextBox>
                            </div>
                            <div class="co-modal-flex-row">
                                <div class="flex-1">
                                    <label class="form-label text-muted co-modal-lbl-styled">City</label>
                                    <asp:TextBox ID="txtCity" runat="server" CssClass="form-control" placeholder="City"></asp:TextBox>
                                </div>
                                <div class="flex-1">
                                    <label class="form-label text-muted co-modal-lbl-styled">State</label>
                                    <asp:TextBox ID="txtState" runat="server" CssClass="form-control" placeholder="State"></asp:TextBox>
                                </div>
                            </div>
                            <div class="co-modal-flex-row">
                                <div class="flex-1">
                                    <label class="form-label text-muted co-modal-lbl-styled">Pincode / ZipCode</label>
                                    <asp:TextBox ID="txtZip" runat="server" CssClass="form-control" placeholder="ZipCode"></asp:TextBox>
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
                                <label for="<%= chkDefault.ClientID %>" class="co-modal-chk-lbl">Make this my default address</label>
                            </div>

                            <asp:Label ID="lblModalError" runat="server" ForeColor="Red" Font-Size="13px"
                                Visible="false"></asp:Label>
                        </div>
                        <div class="custom-modal-footer co-modal-ftr">
                            <button type="button" class="btn btn-light co-modal-btn-cancel" onclick="closeAddressModal()">Cancel</button>
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
                    if (!document.getElementById('<%= hfSelectedPayment.ClientID %>').value) {
                        if (typeof showToast === 'function') showToast('Please select a payment method', 'warning');
                        else alert('Please select a payment method');
                        return;
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
                const paymentText = method === 'COD' ? '<i class="fas fa-money-bill-wave co-text-green"></i> Cash on Delivery (COD)' : '<i class="fas fa-laptop-code co-text-green"></i> Secure Online Payment';

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

                    const grandTotal = subtotal + baseFee + cfgPlatFee;
                    const totalEl = document.getElementById('js-checkout-grand-total');
                    if (totalEl) {
                        totalEl.innerText = grandTotal.toLocaleString('en-IN');
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
            });
        </script>
    </asp:Content>