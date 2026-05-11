<%@ Page Title="Login" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="ecommerce_mlm.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .login-container {
            max-width: 400px;
            margin: 60px auto;
            padding: 30px;
            background-color: var(--white);
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        .login-container h2 {
            text-align: center;
            margin-bottom: 20px;
            color: var(--primary-color);
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
        }
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid var(--border-color);
            border-radius: 5px;
            font-size: 16px;
        }
        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
        }
        .btn-full {
            width: 100%;
        }
        .error-message {
            color: red;
            text-align: center;
            margin-bottom: 15px;
            font-weight: bold;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container">
        <div class="login-container">
            <h2>User Login</h2>
            
            <asp:Label ID="lblError" runat="server" CssClass="error-message" Visible="false"></asp:Label>
            
            <div class="form-group">
                <label for="txtUsername">Username</label>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Enter username"></asp:TextBox>
            </div>
            
            <div class="form-group">
                <label for="txtPassword">Password</label>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Enter password"></asp:TextBox>
            </div>
            
            <div class="form-group">
                <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn btn-primary btn-full" OnClick="btnLogin_Click" />
            </div>
            
            <div style="text-align: center; margin-top: 15px;">
                <p>Don't have an account? <a href="#" style="color: var(--primary-color);">Register here</a></p>
            </div>
        </div>
    </div>
</asp:Content>
