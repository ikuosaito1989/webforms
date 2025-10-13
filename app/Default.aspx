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
      <asp:Label
        ID="Label1"
        runat="server"
        Text="Hello from CodeBehind!"
      ></asp:Label>
      <br />
      <asp:Button ID="Btn" runat="server" Text="PostBack" OnClick="Btn_Click" />
    </form>
  </body>
</html>
