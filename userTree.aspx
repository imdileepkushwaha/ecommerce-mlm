<%@ Page Title="Genealogy Tree" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true"
    CodeFile="userTree.aspx.cs" Inherits="ecommerce_mlm.userTree" %>
    <%@ Register Src="~/UserSidebar.ascx" TagPrefix="uc" TagName="UserSidebar" %>

        <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
            <style>
                .btn-pill-modern {

                    min-width: 145px;
                    width: 100%;
                    justify-content: center;
                }
            </style>
        </asp:Content>

        <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
            <section class="dashboard-wrapper">
                <div class="dashboard-breadcrumb">
                    <div class="container">
                        <div class="dashboard-breadcrumb-inner">
                            <div class="breadcrumb-left">
                                <h3>Network Tree View</h3>
                            </div>
                            <div class="breadcrumb-right">
                                <a href="index.aspx"><i class="fas fa-home"></i></a>
                                <span> / Genealogy</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="container">
                    <div class="dashboard-layout">
                        <!-- Sidebar Navigation -->
                        <uc:UserSidebar runat="server" ID="UserSidebar" />

                        <!-- Tree Content -->
                        <main class="dashboard-main-content">

                            <!-- CONTROLS HEADER (SEARCH & LEGEND) -->
                            <div
                                style="display: flex; justify-content: space-between; align-items: center; background: #fff; padding: 20px; border-radius: 16px; border: 1px solid #f1f5f9; margin-bottom: 25px; flex-wrap: wrap; gap: 15px;">

                                <!-- Search Panel -->
                                <div style="display: flex; gap: 10px; align-items: center;">
                                    <asp:TextBox ID="txtSearchUser" runat="server" CssClass="form-control-custom"
                                        placeholder="Enter Username to Search..." style="min-width:220px; margin:0;">
                                    </asp:TextBox>
                                    <asp:LinkButton ID="btnSearch" runat="server"
                                        CssClass="btn-pill-modern btn-orange-grad"
                                        style="padding: 12px 20px; font-size:0.85rem;" OnClick="btnSearch_Click">
                                        <i class="fas fa-search"></i> View Tree
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnReset" runat="server"
                                        CssClass="btn-pill-modern btn-soft-outline"
                                        style="padding: 12px 20px; font-size:0.85rem;" OnClick="btnReset_Click">
                                        <i class="fas fa-undo"></i> Reset to Self
                                    </asp:LinkButton>
                                </div>

                                <!-- Visual Legend -->
                                <div style="display: flex; gap: 15px;">
                                    <div
                                        style="display: flex; align-items: center; gap: 5px; font-size: 0.8rem; font-weight: 600; color:#1e293b;">
                                        <div style="width:12px; height:12px; background:#22c55e; border-radius:3px;">
                                        </div> Active
                                    </div>
                                    <div
                                        style="display: flex; align-items: center; gap: 5px; font-size: 0.8rem; font-weight: 600; color:#1e293b;">
                                        <div style="width:12px; height:12px; background:#ef4444; border-radius:3px;">
                                        </div> Deactive
                                    </div>
                                    <div
                                        style="display: flex; align-items: center; gap: 5px; font-size: 0.8rem; font-weight: 600; color:#1e293b;">
                                        <div
                                            style="width:12px; height:12px; background:#cbd5e1; border-radius:3px; border:1px dashed #94a3b8;">
                                        </div> Available
                                    </div>
                                </div>
                            </div>

                            <asp:Label ID="lblMsg" runat="server" ForeColor="Red" Font-Bold="true"
                                style="display:block; margin-bottom:10px;"></asp:Label>

                            <!-- ACTUAL SCROLLABLE TREE DISPLAY -->
                            <div class="tree-outer-container">
                                <div class="genealogy-tree">
                                    <asp:Literal ID="litTreeOutput" runat="server"></asp:Literal>
                                </div>
                            </div>

                        </main>
                    </div>
                </div>
            </section>
        </asp:Content>