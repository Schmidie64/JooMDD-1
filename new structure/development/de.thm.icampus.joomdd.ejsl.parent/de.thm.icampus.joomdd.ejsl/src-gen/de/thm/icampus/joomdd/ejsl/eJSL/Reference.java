/**
 * generated by iCampus (JooMDD team) 2.9.1
 */
package de.thm.icampus.joomdd.ejsl.eJSL;

import org.eclipse.emf.ecore.EObject;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Reference</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link de.thm.icampus.joomdd.ejsl.eJSL.Reference#getAttribute <em>Attribute</em>}</li>
 *   <li>{@link de.thm.icampus.joomdd.ejsl.eJSL.Reference#getEntity <em>Entity</em>}</li>
 *   <li>{@link de.thm.icampus.joomdd.ejsl.eJSL.Reference#getAttributerefereced <em>Attributerefereced</em>}</li>
 *   <li>{@link de.thm.icampus.joomdd.ejsl.eJSL.Reference#getLower <em>Lower</em>}</li>
 *   <li>{@link de.thm.icampus.joomdd.ejsl.eJSL.Reference#getUpper <em>Upper</em>}</li>
 * </ul>
 *
 * @see de.thm.icampus.joomdd.ejsl.eJSL.EJSLPackage#getReference()
 * @model
 * @generated
 */
public interface Reference extends EObject
{
  /**
   * Returns the value of the '<em><b>Attribute</b></em>' reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Attribute</em>' reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Attribute</em>' reference.
   * @see #setAttribute(Attribute)
   * @see de.thm.icampus.joomdd.ejsl.eJSL.EJSLPackage#getReference_Attribute()
   * @model
   * @generated
   */
  Attribute getAttribute();

  /**
   * Sets the value of the '{@link de.thm.icampus.joomdd.ejsl.eJSL.Reference#getAttribute <em>Attribute</em>}' reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Attribute</em>' reference.
   * @see #getAttribute()
   * @generated
   */
  void setAttribute(Attribute value);

  /**
   * Returns the value of the '<em><b>Entity</b></em>' reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Entity</em>' reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Entity</em>' reference.
   * @see #setEntity(Entity)
   * @see de.thm.icampus.joomdd.ejsl.eJSL.EJSLPackage#getReference_Entity()
   * @model
   * @generated
   */
  Entity getEntity();

  /**
   * Sets the value of the '{@link de.thm.icampus.joomdd.ejsl.eJSL.Reference#getEntity <em>Entity</em>}' reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Entity</em>' reference.
   * @see #getEntity()
   * @generated
   */
  void setEntity(Entity value);

  /**
   * Returns the value of the '<em><b>Attributerefereced</b></em>' reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Attributerefereced</em>' reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Attributerefereced</em>' reference.
   * @see #setAttributerefereced(Attribute)
   * @see de.thm.icampus.joomdd.ejsl.eJSL.EJSLPackage#getReference_Attributerefereced()
   * @model
   * @generated
   */
  Attribute getAttributerefereced();

  /**
   * Sets the value of the '{@link de.thm.icampus.joomdd.ejsl.eJSL.Reference#getAttributerefereced <em>Attributerefereced</em>}' reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Attributerefereced</em>' reference.
   * @see #getAttributerefereced()
   * @generated
   */
  void setAttributerefereced(Attribute value);

  /**
   * Returns the value of the '<em><b>Lower</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Lower</em>' attribute isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Lower</em>' attribute.
   * @see #setLower(String)
   * @see de.thm.icampus.joomdd.ejsl.eJSL.EJSLPackage#getReference_Lower()
   * @model
   * @generated
   */
  String getLower();

  /**
   * Sets the value of the '{@link de.thm.icampus.joomdd.ejsl.eJSL.Reference#getLower <em>Lower</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Lower</em>' attribute.
   * @see #getLower()
   * @generated
   */
  void setLower(String value);

  /**
   * Returns the value of the '<em><b>Upper</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Upper</em>' attribute isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Upper</em>' attribute.
   * @see #setUpper(String)
   * @see de.thm.icampus.joomdd.ejsl.eJSL.EJSLPackage#getReference_Upper()
   * @model
   * @generated
   */
  String getUpper();

  /**
   * Sets the value of the '{@link de.thm.icampus.joomdd.ejsl.eJSL.Reference#getUpper <em>Upper</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Upper</em>' attribute.
   * @see #getUpper()
   * @generated
   */
  void setUpper(String value);

} // Reference
