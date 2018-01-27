/* --------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See License.txt in the project root for license information.
 * ------------------------------------------------------------------------------------------ */
"use strict";

import {
  IPCMessageReader,
  IPCMessageWriter,
  createConnection,
  IConnection,
  TextDocumentSyncKind,
  TextDocuments,
  TextDocument,
  Diagnostic,
  DiagnosticSeverity,
  InitializeParams,
  InitializeResult,
  TextDocumentPositionParams,
  CompletionItem,
  CompletionItemKind,
  TextEdit,
  DocumentFormattingParams,
  RequestHandler,
  ExecuteCommandParams,
  CodeActionParams
} from "vscode-languageserver";
import { IndentationHandler } from "./components/indentation";
import { VariableHandler } from "./components/variable";
import { ReadabilityHandler } from "./components/readability";
import { KeywordHandler } from "./components/keyword";

// Create a connection for the server. The connection uses Node's IPC as a transport
let connection: IConnection = createConnection(
  new IPCMessageReader(process),
  new IPCMessageWriter(process)
);

let documents: TextDocuments = new TextDocuments();
documents.listen(connection);

let workspaceRoot: string;
connection.onInitialize((params): InitializeResult => {
  workspaceRoot = params.rootPath;
  return {
    capabilities: {
      textDocumentSync: documents.syncKind,
      documentFormattingProvider: true,
      executeCommandProvider: {
        commands: ['alform.indent']
      }
    }
  };
});

connection.onDocumentFormatting((documentFormattingParams: DocumentFormattingParams): TextEdit[] => {
  return oldFormatter(documentFormattingParams);
});

function oldFormatter(documentFormattingParams: DocumentFormattingParams): TextEdit[] {
  let edits: TextEdit[] = [];
  let keywordHandler: KeywordHandler = new KeywordHandler();
  let indentationHandler: IndentationHandler = new IndentationHandler();
  let variableHandler: VariableHandler = new VariableHandler();
  let readabilityHandler: ReadabilityHandler = new ReadabilityHandler();
  let doc: string = documents
    .get(documentFormattingParams.textDocument.uri)
    .getText();

  doc = keywordHandler.casing(doc);
  doc = variableHandler.sort(doc);

  doc = readabilityHandler.spacing(doc);
  doc = indentationHandler.indent(doc, tabSize);

  let lines = doc.split(/\r?\n/g);
  lines.forEach((line, i) => {
    edits.push({
      newText: line,
      range: {
        start: { line: i, character: 0 },
        end: { line: i, character: Number.MAX_VALUE }
      }
    });
  });
  return edits;
}

let t: Thenable<string>;

interface Settings {
  editor: EditorSettings;
  alform: ALFormSettings;
}

interface EditorSettings {
  tabSize: number;
  detectIndentation: boolean;
}

interface ALFormSettings {
  lineLength: number;
  experimental: boolean;
}

let tabSize: number;
let lineLength: number;
let experimental: boolean;
connection.onDidChangeConfiguration(change => {
  let settings = <Settings>change.settings;
  if (settings.editor.detectIndentation) {
    tabSize = 2;
  } else {
    tabSize = settings.editor.tabSize;
  }
  lineLength = settings.alform.lineLength;
  experimental = settings.alform.experimental;
});

// Listen on the connection
connection.listen();
