// @flow
import React, { Component } from 'react'
import { render } from 'react-dom'

import styles from './styles.css'

export default class App extends Component<*, *> {
  async componentDidMount() {
    const response = await fetch('api')
    const message = response.ok
      ? await response.text()
      : 'The server is sad. :('
    this.setState({ text: message })
  }

  render() {
    return (
      <div>
        <div className={styles.hello}>Hello world!</div>
        {this.state && this.state.text && (
          <div className={styles.helloApi}>{this.state.text}</div>
        )}
      </div>
    )
  }
}

const root = document.getElementById('app')
if (root) {
  render(<App />, root)
}
