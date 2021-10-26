import { Logo } from 'components/Logo'
import PropTypes from 'prop-types'
import React from 'react'
import src from '../../images/plugin-logo.png'

const Main = (props) => {
  return <Logo src={src} alt="Plugin Node" {...props} width="30%"/>
}

Main.propTypes = {
  width: PropTypes.number,
  height: PropTypes.number,
}

export default Main
