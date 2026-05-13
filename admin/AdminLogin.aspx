<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AdminLogin.aspx.cs" Inherits="ecommerce_mlm.admin.AdminLogin" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Admin Central - Authorization</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="../assets/fonts/fontawesome/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <style>
        :root {
            --primary: #0f172a;
            --accent: #f97316;
            --bg: #f8fafc;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Plus Jakarta Sans', sans-serif; }
        body {
            background: radial-gradient(circle at top right, #1e293b, #0f172a);
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }
        .glass-layer {
            position: absolute;
            width: 100%;
            height: 100%;
            background: url('https://www.transparenttextures.com/patterns/cube.png');
            opacity: 0.05;
            pointer-events: none;
        }
        .login-container {
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(15px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 24px;
            width: 100%;
            max-width: 420px;
            padding: 45px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            position: relative;
            z-index: 10;
            animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1);
        }
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .brand-box {
            text-align: center;
            margin-bottom: 35px;
        }
        .brand-box .logo-circle {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #f97316, #c2410c);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            color: #fff;
            margin: 0 auto 15px;
            box-shadow: 0 10px 20px rgba(249, 115, 22, 0.3);
        }
        .brand-box h2 {
            color: #fff;
            font-weight: 800;
            font-size: 1.6rem;
            letter-spacing: -0.5px;
        }
        .brand-box p {
            color: #94a3b8;
            font-size: 0.9rem;
            margin-top: 5px;
        }
        .form-group {
            margin-bottom: 20px;
            position: relative;
        }
        .form-group label {
            display: block;
            color: #cbd5e1;
            font-size: 0.8rem;
            font-weight: 600;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .input-icon-wrapper {
            position: relative;
        }
        .input-icon-wrapper i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #64748b;
            transition: 0.3s;
        }
        .form-input {
            width: 100%;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 12px;
            padding: 14px 15px 14px 45px;
            color: #fff;
            font-size: 0.95rem;
            outline: none;
            transition: all 0.3s;
        }
        .form-input:focus {
            background: rgba(255,255,255,0.08);
            border-color: var(--accent);
            box-shadow: 0 0 0 4px rgba(249, 115, 22, 0.1);
        }
        .form-input:focus + i { color: var(--accent); }
        .btn-auth {
            width: 100%;
            background: linear-gradient(135deg, #f97316, #ea580c);
            color: #fff;
            border: none;
            border-radius: 12px;
            padding: 15px;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            transition: 0.3s;
            margin-top: 10px;
            box-shadow: 0 10px 20px rgba(234, 88, 12, 0.2);
        }
        .btn-auth:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 30px rgba(234, 88, 12, 0.3);
        }
        .alert-msg {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: #fca5a5;
            padding: 12px;
            border-radius: 10px;
            font-size: 0.85rem;
            text-align: center;
            margin-bottom: 20px;
            display: none;
        }
        .alert-msg.visible { display: block; }
    </style>
</head>
<body>
    <div class="glass-layer"></div>
    <form id="form1" runat="server">
        <div class="login-container">
            <div class="brand-box">
                <div class="logo-circle"><i class="fas fa-shield-alt"></i></div>
                <h2>Admin Central</h2>
                <p>Secure infrastructure gateway authorization</p>
            </div>

            <asp:Panel ID="pnlAlert" runat="server" CssClass="alert-msg" Visible="false">
                <asp:Label ID="lblError" runat="server" Text="Invalid access credentials."></asp:Label>
            </asp:Panel>

            <div class="form-group">
                <label>Admin Domain ID</label>
                <div class="input-icon-wrapper">
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-input" placeholder="admin@system.com"></asp:TextBox>
                    <i class="far fa-envelope"></i>
                </div>
            </div>

            <div class="form-group">
                <label>Access Protocol Cipher</label>
                <div class="input-icon-wrapper">
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-input" TextMode="Password" placeholder="••••••••"></asp:TextBox>
                    <i class="fas fa-lock"></i>
                </div>
            </div>

            <asp:Button ID="btnLogin" runat="server" CssClass="btn-auth" Text="ESTABLISH CONNECTION" OnClick="btnLogin_Click" />

            <div style="text-align:center; margin-top:25px;">
                <a href="../index.aspx" style="color:#64748b; font-size:0.8rem; text-decoration:none; transition:0.3s;"><i class="fas fa-arrow-left"></i> Return to Public Sphere</a>
            </div>
        </div>
    </form>
</body>
</html>
