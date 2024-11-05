import * as vscode from 'vscode';
export class NewsletterView {
    constructor(private readonly context: vscode.Memento) {
        this.context = context;
    }
	GenerateWebviewContent(extensionUri: vscode.Uri, webview: vscode.Webview) {
        const webviewToolkitUri = webview.asWebviewUri(vscode.Uri.joinPath(extensionUri, "node_modules", "@vscode-elements", "elements", "dist", "bundled.js"));
		webview.html = `<!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <script src="${webviewToolkitUri}" type="module"></script>
            <title>Cosmonauts FYI</title>
        </head>
        <body>
            <h1>⚛️ Cosmonauts FYI</h1>
            <p>Thanks for subscribing to Cosmonauts FYI newsletter by installing the extension! </p>
            <p>Here are some of the most interesting things that happened in the Cosmos last week:</p>
            <h2>🎉 Releases</h2>
            <table>
                <tr>
                    <th>#</th>
                    <th>Organization</th>
                    <th>Repository</th>
                    <th>Tag</th>
                    <th>Link</th>
                </tr>
                <tr>
                    <td>1</td>
                    <td>cosmos</td>
                    <td>ibc-rs</td>
                    <td>v0.55.1</td>
                    <td><a href="https://github.com/cosmos/ibc-rs/releases/tag/v0.55.1"/></td>
                </tr>
            </table>
            <h2>🎯 Issues</h2>
            <table>
                <tr>
                    <th>#</th>
                    <th>Organization</th>
                    <th>Repository</th>
                    <th>Issue</th>
                    <th>Link</th>
                </tr>
                <tr>
                    <td>1</td>
                    <td>cosmos</td>
                    <td>cosmos-sdk</td>
                    <td>Issue #21069</td>
                    <td><a href="https://github.com/cosmos/cosmos-sdk/pull/21069"/></td>
                </tr>
            </table>
            <vscode-divider></vscode-divider>
            <h2>🚀 Pull Requests</h2>
            <vscode-table>
                <vscode-table-header slot="header">
                    <vscode-table-header-cell>#</vscode-table-header-cell>
                    <vscode-table-header-cell>Organization</vscode-table-header-cell>
                    <vscode-table-header-cell>Repository</vscode-table-header-cell>
                    <vscode-table-header-cell>Title</vscode-table-header-cell>
                    <vscode-table-header-cell>Created By</vscode-table-header-cell>
                    <vscode-table-header-cell>Merged?</vscode-table-header-cell>
                    <vscode-table-header-cell>Link</vscode-table-header-cell>
                </vscode-table-header>
                <vscode-table-body slot="body">
                    <vscode-table-row>
                        <vscode-table-cell>1</vscode-table-cell>
                        <vscode-table-cell>strangelove-ventures</vscode-table-cell>
                        <vscode-table-cell>interchaintest</vscode-table-cell>
                        <vscode-table-cell>feat(local-ic): stream interaction and container logs</vscode-table-cell>
                        <vscode-table-cell><vscode-icon name="account"></vscode-icon> <a href="https://github.com/Reecepbcups">Reecepbcups</a></vscode-table-cell>
                        <vscode-table-cell><vscode-icon name="git-merge"></vscode-icon></vscode-table-cell>
                        <vscode-table-cell><a href="https://github.com/cometbft/cometbft/issues/4251">#4251</a></vscode-table-cell>
                    </vscode-table-row>
                </vscode-table-body>
            </vscode-table>
        </body>
        </html>`
        return
	}
}