<%@ Page Title="My Catalog Products" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true" CodeFile="Products.aspx.cs" Inherits="EcommerceWebsite.SellerProducts" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <!-- SCRIPTA MANAGER FOR ASYNC REFRESH -->
    <asp:ScriptManager ID="smProducts" runat="server"></asp:ScriptManager>

    <!-- ACTION BAR TOP -->
    <div class="page-action-bar">
        <div class="welcome-title">
            <h1 style="font-size: 1.6rem;"><i class="fas fa-boxes" style="color: var(--accent); margin-right: 8px;"></i>Product Catalog</h1>
            <p>Monitor active listings, track local inventory reserves, and synchronize pricing structures.</p>
        </div>
        
        <a href="AddEditProduct.aspx" class="add-prod-btn">
            <i class="fas fa-plus-circle"></i> Add New Product
        </a>
    </div>

    <!-- GLOBAL SYSTEM MESSAGES -->
    <asp:UpdatePanel ID="upnlMsg" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Label ID="lblGlobalMsg" runat="server" Visible="false" style="display:block; padding:16px 24px; border-radius:12px; margin-bottom:25px; font-size:0.9rem; font-weight:600;"></asp:Label>
        </ContentTemplate>
    </asp:UpdatePanel>

    <!-- MAIN INVENTORY CORE -->
    <div class="prod-card">
        <asp:UpdatePanel ID="upnlGrid" runat="server">
            <ContentTemplate>
                <div class="prod-table-wrap">
                    <asp:Repeater ID="rptProducts" runat="server" OnItemCommand="rptProducts_ItemCommand">
                        <HeaderTemplate>
                            <table class="prod-table">
                                <thead>
                                    <tr>
                                        <th>Item Identity</th>
                                        <th>Category</th>
                                        <th>Commercials</th>
                                        <th>Stock Flow</th>
                                        <th>Visibility Switch</th>
                                        <th>Status</th>
                                        <th style="text-align: center;">Action Console</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div class="p-item-meta">
                                        <div class="p-thumb-box">
                                            <%# GetProductImage(Eval("ThumbnailUrl"), Eval("MainImage")) %>
                                        </div>
                                        <div class="p-info-block">
                                            <h4><%# Eval("Name") %></h4>
                                            <span><i class="fas fa-tag u-mr-5" style="font-size: 0.65rem;"></i>SKU: <%# Eval("Sku") %></span>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <strong style="color: #475569;"><%# Eval("Category") %></strong>
                                </td>
                                <td>
                                    <span class="price-label">₹<%# Convert.ToDecimal(Eval("Price")).ToString("N2") %></span>
                                    <span class="mrp-label">₹<%# Convert.ToDecimal(Eval("Mrp")).ToString("N2") %></span>
                                </td>
                                <td>
                                    <%# GetStockBadge(Eval("Stock")) %>
                                </td>
                                <td>
                                    <!-- Interactive Switch Toggle Engine -->
                                    <asp:LinkButton ID="lnkToggleActive" runat="server" 
                                        CommandName="ToggleActive" 
                                        CommandArgument='<%# Eval("Id") %>'
                                        CssClass='<%# Convert.ToBoolean(Eval("IsActive")) ? "ios-switch-btn active" : "ios-switch-btn" %>'
                                        ToolTip="Click to toggle visibility on storefront"></asp:LinkButton>
                                </td>
                                <td>
                                    <%# GetStatusBadge(Eval("IsActive")) %>
                                </td>
                                <td>
                                    <div class="action-btn-grp" style="justify-content: center;">
                                        <a href='ViewProduct.aspx?id=<%# Eval("Id") %>' class="action-ico action-ico-view" title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href='AddEditProduct.aspx?id=<%# Eval("Id") %>' class="action-ico action-ico-edit" title="Edit Parameters">
                                            <i class="fas fa-pen-to-square"></i>
                                        </a>
                                        <asp:LinkButton ID="lnkDelete" runat="server" 
                                            CommandName="DeleteProduct" 
                                            CommandArgument='<%# Eval("Id") %>' 
                                            CssClass="action-ico action-ico-delete" 
                                            OnClientClick="return confirm('CAUTION: Permanent deletion? This operation will purge the inventory record completely from the active registry.');" 
                                            ToolTip="Delete Record">
                                            <i class="fas fa-trash-can"></i>
                                        </asp:LinkButton>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>

                    <!-- EMPTY RUN ENGINE -->
                    <asp:PlaceHolder ID="phEmptyState" runat="server" Visible="false">
                        <div style="text-align:center; padding:60px 20px;">
                            <div style="font-size:3.5rem; color:#cbd5e1; margin-bottom:15px;"><i class="fas fa-box-open"></i></div>
                            <h4 style="font-weight:800; font-size:1.1rem; color:#0f172a; margin-bottom:6px;">Inventory Is Empty</h4>
                            <p style="color:#64748b; font-size:0.9rem; max-width:400px; margin:0 auto 20px;">You have not indexed any products on your merchant profile yet.</p>
                            <a href="AddEditProduct.aspx" class="add-prod-btn" style="padding:10px 20px; font-size:0.85rem;">
                                <i class="fas fa-plus"></i> Begin Catalog Indexing
                            </a>
                        </div>
                    </asp:PlaceHolder>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

</asp:Content>
