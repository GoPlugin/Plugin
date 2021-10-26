import { Logo } from 'components/Logo'
import PropTypes from 'prop-types'
import React from 'react'
import src from '../../images/plugin-logo.png'

const Hexagon = (props) => {
  return <Logo src={src} alt="Plugin Node" {...props} />
}

Hexagon.propTypes = {
  width: PropTypes.number,
  height: PropTypes.number,
}

export default Hexagon
