<%@ page contentType="text/css;charset=UTF-8" %>
%{-- clearing button BS2 defaults --}%
#main-content :not(.btn-group):not(.input-append):not(.input-prepend)>${selector} {
  text-shadow: none;
  background-image: none;
  background-repeat: no-repeat;
  filter: none;
}

#main-content :not(.btn-group):not(.input-append):not(.input-prepend)>${selector}:focus,
#main-content :not(.btn-group):not(.input-append):not(.input-prepend)>${selector}.focus {
    outline:none;
    outline-offset:0px;
}

#main-content :not(.btn-group):not(.input-append):not(.input-prepend)>${selector} {
  color: ${textColor};
  background-color: ${backColor};
  background-image: none;
  border-color: ${backColor};
}

#main-content :not(.btn-group):not(.input-append):not(.input-prepend)>${selector}:hover {
    color: ${textColor};
    background-color: ${backColor};
    border-color: ${backColor};
    box-shadow: 0 0 0 .2rem <config:convertHexToRGBA hex="${backColor}" alpha="0.5"/>;
}

#main-content :not(.btn-group):not(.input-append):not(.input-prepend)>${selector}:focus,
#main-content :not(.btn-group):not(.input-append):not(.input-prepend)>${selector}.focus {
    color: ${textColor};
    background-color: ${backColor};
    border-color: ${backColor};
    box-shadow: 0 0 0 .2rem <config:convertHexToRGBA hex="${backColor}" alpha="0.5"/>;
}

#main-content :not(.btn-group):not(.input-append):not(.input-prepend)>${selector}.disabled,
#main-content :not(.btn-group):not(.input-append):not(.input-prepend)>${selector}:disabled {
    color: ${textColor};
    background-color: transparent;
}

#main-content :not(.btn-group):not(.input-append):not(.input-prepend)>${selector}:not(:disabled):not(.disabled):active,
#main-content :not(.btn-group):not(.input-append):not(.input-prepend)>${selector}:not(:disabled):not(.disabled).active {
    color: ${textColor};
    background-color: ${backColor};
    border-color: ${backColor};
    box-shadow: 0 0 0 0 ${backColor};
}
