import { KeywordHandler } from "./keyword";
export class IndentationHandler {
  private level: string[];
  private lines: string[];
  private edits: string[];
  private indents: number;
  private _tabSize: number;
  private multiLineComment: boolean = false;

  public indent(doc: string, tabSize: number): string {
    this.lines = doc.split(/\r?\n/g);
    this._tabSize = tabSize;
    this.edits = [];
    this.level = [];

    this.lines.forEach((line, i) => {
      this.indentCurr(line, i);
      this.edits.push(`${this.genTabs(this.indents)}${line.trim()}`);
      this.indentNext(line, i);
    });

    return this.edits.join("\n");
  }

  private indentCurr(line: string, i: number) {
    let words: string[] = KeywordHandler.keywordSplit(line);
    let comment: boolean = false;
    if (words) {
      words.forEach(word => {
        if (word === "//") comment = true;
        if (word === "/*") this.multiLineComment = true;
        if (!comment && !this.multiLineComment) {
          switch (word) {
            case "}":
              if (this.level[this.level.length - 1] === "var") this.level.pop();
              if (!KeywordHandler.keywordExists("{", words)) this.level.pop();
              break;
            case "procedure":
              if (this.level[this.level.length - 1] === "var") this.level.pop();
              break;
            case "trigger":
              if (this.level[this.level.length - 1] === "var") this.level.pop();
              break;
            case "begin":
              if (this.level[this.level.length - 1] === "var") this.level.pop();
              break;
            case "BusinessEvent":
              if (this.level[this.level.length - 1] === "var") this.level.pop();
              break;
            case "IntegrationEvent":
              if (this.level[this.level.length - 1] === "var") this.level.pop();
              break;
            case "EventSubscriber":
              if (this.level[this.level.length - 1] === "var") this.level.pop();
              break;
            case "end":
              this.level.pop();
              break;
            case "else":
              if (this.level[this.level.length - 1] === "then")
                this.level.pop();
              if (this.level[this.level.length - 1] === "case") {
                this.level.pop();
                this.level.push("caseelse");
              }
              break;
            case "until":
              if (this.level[this.level.length - 1] === "repeat")
                this.level.pop();
              break;
            case "then":
              if (this.level[this.level.length - 1] === "if") this.level.pop();
              break;
            case "var":
              if (this.level[this.level.length - 1] === "var")
                this.level.pop();
            default:
              break;
          }
        }
        if (word === "*/") this.multiLineComment = false;
      });
      this.indents = this.level.length;
      this.level.forEach(level => {
        if (level === "caseelse") {
          this.indents--;
        }
      });
    }
  }

  private indentNext(line: string, i: number) {
    let words: string[] = KeywordHandler.keywordSplit(line);
    let comment: boolean = false;
    if (words) {
      words.forEach(word => {
        if (word === "//") comment = true;
        if (!comment && !this.multiLineComment) {
          switch (word.toLowerCase()) {
            case "{":
              if (!KeywordHandler.keywordExists("}", words))
                this.level.push("{");
              break;
            case "(":
              this.level.push("(");
              break;
            case ")":
              if (this.level[this.level.length - 1] === "Message") {
                this.level.pop();
              }
              this.level.pop();
              break;
            case "var":
              if (!KeywordHandler.keywordExists("procedure", words))
                this.level.push("var");
              break;
            case "begin":
              this.level.push("begin");
              break;
            case "then":
              if (
                !KeywordHandler.keywordExists(";", words) &&
                !KeywordHandler.keywordExists("begin", words) &&
                !KeywordHandler.keywordExists("repeat", words)
              )
                this.level.push("then");
              break;
            case "else":
              if (this.level[this.level.length - 1] === "TableRelation")
                break;
              if (
                !KeywordHandler.keywordExists(";", words) &&
                !KeywordHandler.keywordExists("begin", words)
              )
                this.level.push("else");
              break;
            case ";":
              if (this.level[this.level.length - 1] === "Message")
                this.level.pop();
              while (this.level[this.level.length - 1] === "then") {
                this.level.pop();
              }
              if (this.level[this.level.length - 1] === "else")
                this.level.pop();
              if (this.level[this.level.length - 1] === ":") this.level.pop();
              if (this.level[this.level.length - 1] === "for") this.level.pop();
              if (this.level[this.level.length - 1] === "while")
                this.level.pop();
              if (this.level[this.level.length - 1] === "CaptionML") {
                this.level.pop();
              }
              if (this.level[this.level.length - 1] === "TableRelation") {
                this.level.pop();
              }
              break;
            case "case":
              this.level.push("case");
              break;
            case ":":
              if (this.level[this.level.length - 1] === "case")
                this.level.push(":");
              break;
            case "repeat":
              if (this.level[this.level.length - 1] === "if") this.level.pop();
              this.level.push("repeat");
              break;
            case "for":
              if (!(this.level[this.level.length - 1] === "begin"))
                this.level.push("for");
              break;
            case "while":
              if (!KeywordHandler.keywordExists("begin", words))
                this.level.push("while");
              break;
            case "if":
              if (this.level[this.level.length - 1] === "TableRelation")
                break;
              if (!KeywordHandler.keywordExists("then", words))
                this.level.push("if");
              break;

            case "Error".toLowerCase():
            case "Message".toLowerCase():
            case "StrSubstNo".toLowerCase():
              if (!KeywordHandler.keywordExists(";", words)) {
                this.level.push("Message");
              }
              break;
            case "CaptionML".toLowerCase():
            case "TextConst".toLowerCase():
              if (!KeywordHandler.keywordExists(";", words)) {
                this.level.push("CaptionML");
              }
              break;
            case "TableRelation".toLowerCase():
              this.level.push("TableRelation");
              break;
            default:
              break;
          }
        }
      });
    }
  }

  private genTabs(level: number): string {
    return level == 0
      ? ""
      : Array(level + 1).join(Array(this._tabSize + 1).join(" "));
  }
}
