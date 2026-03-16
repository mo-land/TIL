## links
 <details><summary>links</summary>

[Webエディタ](https://codesandbox.io/p/sandbox/new?file=%2Fsrc%2FApp.js%3A11%2C1)

</details>

## [Reactチュートリアル：三目並べ](https://ja.react.dev/learn/tutorial-tic-tac-toe)

### 盤面の作成

#### 理解したこと
- srcフォルダ・publicフォルダ内の各ファイルの関係性と、データの流れ
- index.htmlはRailsのビューに似ているが、コンポーネントの設定はsrc内でやっているので  
  ここでは最終的な `<div id="hogehoge"></div>` だけ表示する
- App.js を編集して、盤面のマス目を増やす方法
  <details><summary>詳細</summary>

  #### 横に増やす
  複数の隣接する JSX 要素は、以下のようにフラグメント（<> および </>）で囲む
  ```react:App.js
    export default function Square() {
    return (
      <>
        <button className="square">X</button>
        <button className="square">X</button>
      </>
    );
  }
  ```

  #### 縦に増やす
  横一列（`<div className="board-row">...</div>`） のブロックを作り、増やしたい行の文だけ  
  ブロックを丸ごと追加する。
  ```react:App.js
  export default function Board() {
    return (
      <>
        <div className="board-row">
          <button className="square">1</button>
          <button className="square">2</button>
          <button className="square">3</button>
        </div>
        <div className="board-row">
          <button className="square">4</button>
          <button className="square">5</button>
          <button className="square">6</button>
        </div>
        <div className="board-row">
          <button className="square">7</button>
          <button className="square">8</button>
          <button className="square">9</button>
        </div>
      </>
    );
  }
  ```

  </details>

### propsを通してデータを渡す

#### 理解したこと
- ブラウザの`div`とは異なり、自分で作成するコンポーネントである`Board`と`Square`は、大文字で始める必要があることに注意する
- `function Square({ value })` は、`Square` コンポーネントに props として `value` という名前の値が渡されることを示す
- コンポーネント間の「レンダーしている/されている」「propsを渡す/受け取る」の相互関係の仕組み  
  -  `親コンポーネントが子コンポーネントを呼び出し、そのときに値を渡す。
子コンポーネントは受け取って使う。`とだけ考えると楽 [byちゃじぴ](https://chatgpt.com/share/69b7e974-aeb8-800c-a476-588695c16eae)
  - レンダーするのは親 / レンダーされるのは子
- 今回のチュートリアルでは、`Squqre`コンポーネントが子で、`Board`コンポーネントが親。
#### 理解できていないこと
- 以下のコードで、`Square`コンポーネントだけ冒頭に exportなどが無いのはなぜ？  
  子コンポーネントだからかな？
```
function Square({ value }) {
  return <button className="square">{value}</button>;
}

export default function Board() {
  return (
    <>
      <div className="board-row">
        <Square value="1" />
        <Square value="2" />
        <Square value="3" />
      </div>

      … 省略 …

    </>
  );
}

```



## 感想