<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs"
Inherits="_Default" %>
<!DOCTYPE html>
<html>
  <head runat="server">
    <meta charset="utf-8" />
    <title>Mono WebForms CodeBehind</title>
  </head>
  <body>
    <form id="form1" runat="server">
      <h1>Mono + Web Forms (CodeBehind)</h1>
      <asp:Label ID="Label1" runat="server" Text="Hello from CodeBehind!"></asp:Label>
      <br />
      <asp:Button ID="Btn" runat="server" Text="DB PostBack" OnClick="Btn_Click" />

      <hr />
      <h2>File Read/Write (App_Data/data.txt)</h2>
      <asp:Label ID="StatusLabel" runat="server" ForeColor="Maroon"></asp:Label>
      <br />
      <asp:TextBox ID="FileContent" runat="server" TextMode="MultiLine" Rows="10" Columns="80" ReadOnly="true"></asp:TextBox>
      <br />
      <asp:TextBox ID="NewLine" runat="server" Columns="60" placeholder="追記するテキストを入力"></asp:TextBox>
      <asp:Button ID="BtnWrite" runat="server" Text="ファイルに追記" OnClick="BtnWrite_Click" />
    </form>
  </body>
</html>
