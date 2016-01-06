/**
 * generated by iCampus (JooMDD team) 2.9.1
 */
package de.thm.icampus.joomdd.ejsl.eJSL;

import org.eclipse.emf.common.util.EList;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Details Page</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link de.thm.icampus.joomdd.ejsl.eJSL.DetailsPage#getEditfields <em>Editfields</em>}</li>
 * </ul>
 *
 * @see de.thm.icampus.joomdd.ejsl.eJSL.EJSLPackage#getDetailsPage()
 * @model
 * @generated
 */
public interface DetailsPage extends DynamicPage
{
  /**
   * Returns the value of the '<em><b>Editfields</b></em>' containment reference list.
   * The list contents are of type {@link de.thm.icampus.joomdd.ejsl.eJSL.DetailPageField}.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Editfields</em>' containment reference list isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Editfields</em>' containment reference list.
   * @see de.thm.icampus.joomdd.ejsl.eJSL.EJSLPackage#getDetailsPage_Editfields()
   * @model containment="true"
   * @generated
   */
  EList<DetailPageField> getEditfields();

} // DetailsPage
