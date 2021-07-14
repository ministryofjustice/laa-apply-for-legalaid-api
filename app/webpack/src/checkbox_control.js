document.addEventListener('DOMContentLoaded', event => {
  /*
    Usage:
      Required: A group of checkboxes,
        and another control checkbox outside the group

      Enclose the checkbox group with a div of class "deselect-group"
        and set it's "data-deselect-ctrl" to the jquery identifier for the control checkbox
  */

  document.querySelectorAll('.deselect-group').forEach((container) => {
    const control = document.querySelector(container.getAttribute('data-deselect-ctrl'))

    const checkboxMemory = []
    const checkboxes = container.querySelectorAll('input[type=checkbox]')

    const hiddenFieldMemory = []
    const hideableFields = container.querySelectorAll('.govuk-checkboxes__conditional')

    /*
      Monitor changes of the control
      For each checkbox within the container,
      If control is selected:
        remember how checkbox was set
        and set checkbox to false
      If deselected:
        Set each checkbox based on its remembered state
    */

    control.addEventListener('change', function () {
      const controlChecked = this.checked

      if (this.checked) {
        control.checked = true
        control.value = true
      } else {
        control.checked = false
        control.value = ''
      }

      checkboxes.forEach((checkbox, index) => {
        if (controlChecked) {
          checkboxMemory[index] = checkbox.checked
          checkbox.checked = false
        } else {
          checkbox.checked = checkboxMemory[index]
        }
      })

      hideableFields.forEach((hideableField, index) => {
        if (controlChecked) {
          if (!hideableField.classList.contains('govuk-checkboxes__conditional--hidden')) {
            hideableField.classList.add('govuk-checkboxes__conditional--hidden')
            hiddenFieldMemory[index] = true
          } else {
            hiddenFieldMemory[index] = false
          }
        } else if (hiddenFieldMemory[index]) {
          hideableField.classList.remove('govuk-checkboxes__conditional--hidden')
        }
      })
    })

    /*
      Monitor changes to the checkboxes within the container.
      If one is selected, deselect the control.
    */
    checkboxes.forEach((checkbox) => {
      checkbox.addEventListener('change', function () {
        if (checkbox.checked) {
          control.checked = false
          control.value = ''
        }
      })
    })
  })
})
