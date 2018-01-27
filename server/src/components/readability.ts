import { KeywordHandler } from "./keyword";
export class ReadabilityHandler {
  private lines: string[];
  private words: string[];
  private newWords: string[];
  /**
     * spacing_binaryoperator
     */
  public spacing(doc: string): string {
    this.lines = doc.split(/\r?\n/g);
    let edits: string[] = [];

    let codeBlock: boolean = false;
    this.lines.forEach((line, i) => {
      if (KeywordHandler.keywordExists("begin", line)) {
        codeBlock = true;
      }
      if (codeBlock && KeywordHandler.keywordExists("end", line)) {
        let j: number = i + 1;
        while (/^(\s*\/\/.*)$|^\s*$/g.test(this.lines[j])) {
          j++;
        }
        if (
          KeywordHandler.keywordExists("procedure", this.lines[j]) ||
          KeywordHandler.keywordExists("}", this.lines[j]) ||
          KeywordHandler.keywordExists("var", this.lines[j]) ||
          KeywordHandler.keywordExists("trigger", this.lines[j])
        ) {
          codeBlock = false;
        }
      }

      if (codeBlock) {
        // this.words = line.match(/\/\/[\s\S]*|'.*?'|".*?"|[\w\d]+|[.\S]/g);
        this.words = line.match(/\/\/[\s\S]*|'([^']|(''))*'|".*?"|[\w\d]+|[.\S]/g);
        this.newWords = [];
        if (this.words) {
          let comment: boolean = false;
          this.words.forEach((word, j) => {
            let spacing: Spacing = new Spacing();
            if (word === "//") comment = true;
            if (!this.isSpace(word) && !comment) {
              this.determineBinaryOperatorSpacing(j, spacing);

              this.preWordSpacing(spacing);
              this.newWords.push(word);
              this.postWordSpacing(spacing);
            } else if (comment) {
              this.newWords.push(word);
            }
          });

          if (this.newWords[this.newWords.length - 1] === "<NOSPACE>")
            this.newWords.pop();

          edits.push(this.newWords.join(""));
        } else edits.push(line);
      } else edits.push(line);
    });

    return edits.join("\n");
  }

  private determineBinaryOperatorSpacing(index: number, spacing: Spacing) {
    let word: string = this.words[index];

    switch (word) {
      case ":":
        if (this.words[index + 1] === "=") spacing.after = false;
        else spacing.before = false;

        if (this.words[index + 1] === ":" || this.words[index - 1] === ":") {
          spacing.after = false;
          spacing.before = false;
        }

        break;
      case "=":
        if (this.words[index - 1] === ":" || 
          this.words[index - 1] === "+" ||
        this.words[index - 1] === "-") spacing.before = false;
        break;
      case ";":
      case ")":
      case "]":
        spacing.before = false;
        break;
      case "(":
        spacing.after = false;
        spacing.before = false;
        if (
          this.words[index - 1] === "or" ||
          this.words[index - 1] === "and" ||
          this.words[index - 1] === "not" ||
          this.words[index - 1] === "<" ||
          this.words[index - 1] === ">" ||
          this.words[index - 1] === "-" ||
          this.words[index - 1] === "+" ||
          this.words[index - 1] === "/" ||
          this.words[index - 1] === "*"
        ) {
          spacing.before = true;
        }
        break;
      case ".":
      case ",":
        spacing.before = false;
        spacing.after = false;
        break;
      case "<":
      case ">":
        if (
          this.words[index + 1] === "=" ||
          this.words[index + 1] === "<" ||
          this.words[index + 1] === ">"
        ) {
          spacing.after = false;
        }
        break;
      case "[":
        spacing.after = false;
        break;
      default:
        break;
    }
  }

  private preWordSpacing(spacing: Spacing) {
    if (spacing.before) {
      if (this.newWords[this.newWords.length - 1] === "<NOSPACE>") {
        this.newWords.pop();
      } else if (!this.isSpace(this.newWords[this.newWords.length - 1])) {
        this.newWords.push(" ");
      }
    } else {
      if (this.isSpace(this.newWords[this.newWords.length - 1])) {
        this.newWords.pop();
      }
    }

    if (this.newWords[this.newWords.length - 1] === "<NOSPACE>") {
      this.newWords.pop();
    }
  }

  private postWordSpacing(spacing: Spacing) {
    if (spacing.after) {
      this.newWords.push(" ");
    } else {
      this.newWords.push("<NOSPACE>");
    }
  }

  private isSpace(word: string): boolean {
    return /^\s+$/g.test(word);
  }
}

class Spacing {
  before: boolean = true;
  after: boolean = true;
}
