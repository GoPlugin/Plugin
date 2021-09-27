import { Logo } from 'components/Logo'
import PropTypes from 'prop-types'
import React from 'react'
import src from '../../images/2.svg'

const Main = (props) => {
  return <Logo src={src} alt="Plugin Operator" {...props} />
}

Main.propTypes = {
  width: PropTypes.number,
  height: PropTypes.number,
}

export default Main
