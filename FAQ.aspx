<%@ Page Title="FAQ" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true" CodeFile="FAQ.aspx.cs"
    Inherits="ecommerce_mlm.FAQ" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            .faq-icon-rot {
                transition: transform 0.3s ease;
            }

            .faq-card.active .faq-icon-rot {
                transform: rotate(180deg);
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="dashboard-breadcrumb">
            <div class="container">
                <div class="dashboard-breadcrumb-inner">
                    <div class="breadcrumb-left">
                        <h3>FAQ</h3>
                    </div>
                    <div class="breadcrumb-right">
                        <a href="index.aspx"><i class="fas fa-home"></i></a>
                        <span> / FAQ</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="container">

            <div class="standard-content-box" style="padding:30px 40px; margin-bottom:30px;">
                <h1 style="color:#1e293b; font-weight:800; margin:0 0 5px; font-size:2rem;">Frequently Asked Questions
                </h1>
                <p style="margin:0; color:#64748b;">Get instant answers to generalized operational and fiscal queries.
                </p>
            </div>

            <div class="faq-card active">
                <div class="faq-header" onclick="toggleFaq(this)">
                    <span>How does the dynamic Referral program work?</span>
                    <i class="fas fa-chevron-down faq-icon-rot"></i>
                </div>
                <div class="faq-body" style="display:block;">
                    Each successful registration leveraging your unique code creates a vertex under your grid. Every
                    authenticated trade within your downstream matrix automatically filters a predetermined fractional
                    percentage directly into your reward wallet.
                </div>
            </div>

            <div class="faq-card">
                <div class="faq-header" onclick="toggleFaq(this)">
                    <span>When will I receive the products I ordered?</span>
                    <i class="fas fa-chevron-down faq-icon-rot"></i>
                </div>
                <div class="faq-body">
                    Standard fulfillment is within 3-5 business cycles post-payment locking. Highly rural zones could
                    potentially see up to 7 days depending entirely on local courier saturation. Complete vector
                    tracking resides in your Accounts tab.
                </div>
            </div>

            <div class="faq-card">
                <div class="faq-header" onclick="toggleFaq(this)">
                    <span>Can I withdraw my wallet points anytime?</span>
                    <i class="fas fa-chevron-down faq-icon-rot"></i>
                </div>
                <div class="faq-body">
                    Points must mature past the return-protection barrier of 10 days. Once solidified as 'Available
                    Income', you may trigger batch disbursements immediately to validated primary financial routing
                    channels linked in Settings.
                </div>
            </div>

            <div class="faq-card">
                <div class="faq-header" onclick="toggleFaq(this)">
                    <span>Is it secure to input payment methods?</span>
                    <i class="fas fa-chevron-down faq-icon-rot"></i>
                </div>
                <div class="faq-body">
                    Absolutely. Your sensitive card parameters are encrypted client-side and forwarded directly to
                    institutional-grade vault tokens. Our servers explicitly store absolutely ZERO sensitive numeric
                    keys guaranteeing leak-proof environments.
                </div>
            </div>

        </div>

        <script type="text/javascript">
            function toggleFaq(header) {
                var parent = header.parentElement;
                var body = parent.querySelector('.faq-body');

                // Close all others optionally? Or just toggle this
                if (parent.classList.contains('active')) {
                    parent.classList.remove('active');
                    body.style.display = "none";
                } else {
                    parent.classList.add('active');
                    body.style.display = "block";
                }
            }
        </script>
    </asp:Content>