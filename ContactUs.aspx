<%@ Page Title="Contact Us" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true" CodeFile="ContactUs.aspx.cs" Inherits="ecommerce_mlm.ContactUs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="dashboard-breadcrumb">
        <div class="container">
            <div class="dashboard-breadcrumb-inner">
                <div class="breadcrumb-left">
                    <h3>Contact Us</h3>
                </div>
                <div class="breadcrumb-right">
                    <a href="index.aspx"><i class="fas fa-home"></i></a>
                    <span> / Contact Us</span>
                </div>
            </div>
        </div>
    </div>

    <div class="container" style="margin-top:40px; margin-bottom:80px;">
        <div class="standard-content-box" style="padding:30px 40px; margin-bottom:30px;">
             <h1 style="color:#1e293b; font-weight:800; margin:0 0 5px; font-size:2rem;">Get In Touch</h1>
             <p style="margin:0; color:#64748b;">Have queries or suggestions? Our support engineers are listening.</p>
        </div>

        <div class="contact-grid">
            
            <!-- Left: Visual Block -->
            <div class="contact-info-side">
                <h3 style="color:#f97316; margin-bottom:10px; font-weight:800;">Connect Directly</h3>
                <p style="color:#94a3b8; font-size:0.9rem; margin-bottom:40px;">Reach out via traditional support channels or visit our physical corporate hub.</p>
                
                <div class="contact-item-modern">
                    <div class="c-icon-box"><i class="fas fa-phone-alt"></i></div>
                    <div>
                        <h5 style="margin:0; font-weight:700;">Phone Lines</h5>
                        <p style="margin:0; color:#94a3b8;">+1 (603) 555-0123</p>
                    </div>
                </div>

                <div class="contact-item-modern">
                    <div class="c-icon-box"><i class="fas fa-envelope"></i></div>
                    <div>
                        <h5 style="margin:0; font-weight:700;">Mail Dispatch</h5>
                        <p style="margin:0; color:#94a3b8;">support@kartify.com</p>
                    </div>
                </div>

                <div class="contact-item-modern">
                    <div class="c-icon-box"><i class="fas fa-map-marker-alt"></i></div>
                    <div>
                        <h5 style="margin:0; font-weight:700;">Headquarters</h5>
                        <p style="margin:0; color:#94a3b8;">3228 Bicetown Road,<br/>Huntington, NY 11743</p>
                    </div>
                </div>
            </div>

            <!-- Right: Interactive Block -->
            <div class="standard-content-box" style="padding: 40px; margin-bottom:0;">
                <h3 style="margin-top:0; font-weight:800; color:#1e293b; margin-bottom:20px;">Send a Message</h3>
                
                <div style="display:flex; gap:20px; margin-bottom:20px;">
                    <div style="flex:1;">
                        <label style="font-size:0.85rem; font-weight:700; color:#64748b; display:block; margin-bottom:8px;">Full Name</label>
                        <input type="text" class="form-control-custom" placeholder="Enter name" style="width:100%;" />
                    </div>
                    <div style="flex:1;">
                        <label style="font-size:0.85rem; font-weight:700; color:#64748b; display:block; margin-bottom:8px;">Email Address</label>
                        <input type="email" class="form-control-custom" placeholder="Enter email" style="width:100%;" />
                    </div>
                </div>

                <div style="margin-bottom:20px;">
                    <label style="font-size:0.85rem; font-weight:700; color:#64748b; display:block; margin-bottom:8px;">Subject</label>
                    <input type="text" class="form-control-custom" placeholder="Context of your query" style="width:100%;" />
                </div>

                <div style="margin-bottom:25px;">
                    <label style="font-size:0.85rem; font-weight:700; color:#64748b; display:block; margin-bottom:8px;">Detailed Message</label>
                    <textarea class="form-control-custom" rows="5" placeholder="Elaborate here..." style="width:100%; height:auto;"></textarea>
                </div>

                <button type="button" class="btn-pill-modern btn-orange-grad" style="border:none; width:100%; justify-content:center; font-size:1rem; padding:15px;" onclick="alert('Form integrated visually. Backend routing pending server config.');">
                    Submit Inquiry
                </button>
            </div>

        </div>
    </div>
</asp:Content>
