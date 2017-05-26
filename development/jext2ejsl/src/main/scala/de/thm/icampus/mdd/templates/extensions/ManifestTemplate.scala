package de.thm.icampus.mdd.templates.extensions

import de.thm.icampus.mdd.model.{Author, Manifest}
import de.thm.icampus.mdd.templates.basic.BasicTemplate

/**
  * Created by tobias on 26.05.17.
  */
trait ManifestTemplate extends BasicTemplate {

  def manifestPartial(manifest: Manifest, newline: Boolean = true, indent: Int = 0) : String = {
    val authorOpt = ?(true,
      s"""
         |licence = "${manifest.license.license}""""
    )

    toTemplate(
      s"""
         |Manifestation {
         |    authors ${rep(manifest.authors, authorPartial)}
         |    copyright "${manifest.copyright.copyright}"
         |    licence = "${manifest.license.license}"
         |    $authorOpt
         |}""", newline, indent)
  }

  private def authorPartial(author: Author, newline: Boolean = true, indent: Int = 0) : String = {
    toTemplate(
      s"""
         |Author "${author.name}" {
         |    authoremail = "${author.email}"
         |    authorurl" = "${author.url}"
         |}""", newline, indent)
  }

}
