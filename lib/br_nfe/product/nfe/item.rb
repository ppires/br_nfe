module BrNfe
	module Product
		module Nfe
			class Item < BrNfe::ActiveModelBase
				################################################################################
				############################ INFORMAÇÕES DO PRODUTO ############################
					# Utilizado apenas para fins de validação.
					# informa se o item da NF-e é um produto ou um serviço.
					# 
					# <b>Type: </b> _Symbol_
					# <b>Required: </b> _Yes_
					# <b>Default: </b> _:product_
					# <b>Example: </b> _:service_
					# <b>Avaliable: </b> _one of [:product, :service, :other]_
					#
					attr_accessor :tipo_produto

					# Código do produto ou serviço
					# Preencher com CFOP, caso se trate de itens não relacionados
					# com mercadorias/produtos e que o contribuinte não possua
					# codificação própria. Formato: ”CFOP9999”
					#
					# OBS: Caso não seja preenchido irá pegar automaticamente o valor
					#      da CFOP.
					# 
					# <b>Type:     </b> _String_
					# <b>Required: </b> _Yes_
					# <b>Default:  </b> _CFOP#{cfop}_
					# <b>Example:  </b> _COD65452_
					# <b>Length:   </b> _max: 60_
					#
					attr_accessor :codigo_produto
					def codigo_produto
						@codigo_produto = "CFOP#{cfop}" if @codigo_produto.blank? && cfop.present?
						"#{@codigo_produto}"
					end

					# GTIN (Global Trade Item Number) do produto, antigo código EAN ou código de barras
					# Preencher com o código GTIN-8, GTIN-12, GTIN-13 ou GTIN-14 
					# (antigos códigos EAN, UPC e DUN-14), não informar o conteúdo da TAG 
					# em caso de o produto não possuir este código.
					#
					# OBS: esse atributo sempre vai retornar apenas os números setados 
					#
					# <b>Type:     </b> _Number_
					# <b>Required: </b> _No_
					# <b>Example:  </b> _12345678_
					# <b>Length:   </b> _max: 14_
					#
					attr_accessor :codigo_ean
					alias_attribute :codigo_gtin, :codigo_ean
					def codigo_ean
						"#{@codigo_ean}".gsub(/[^\d]/,'')
					end

					# Descrição do produto ou serviço
					# 
					# <b>Type:     </b> _String_
					# <b>Required: </b> _Yes_
					# <b>Example:  </b> _COPO DE PLÁSTICO 700 ML PARATA_
					# <b>Length:   </b> _max: 120_
					#
					attr_accessor :descricao_produto

					# Código NCM com 8 dígitos 
					# Obrigatória informação do NCM completo (8 dígitos).
					# Nota: Em caso de item de serviço ou item que não tenham
					# produto (ex. transferência de crédito, crédito do ativo
					# imobilizado, etc.), informar o valor 00 (dois zeros). 
					# (NT 2014/004)
					#
					# OBS: esse atributo sempre vai retornar apenas os números
					# 
					# <b>Type:     </b> _Number_
					# <b>Required: </b> _Yes_
					# <b>Example:  </b> _'12345678'_ OR _123454_
					# <b>Length:   </b> _max: 8(:product) OR max: 2(not :product)_
					#
					attr_accessor :codigo_ncm
					def codigo_ncm
						if not is_product?
							@codigo_ncm = '00' if @codigo_ncm.blank?
						end
						"#{@codigo_ncm}".gsub(/[^\d]/,'')
					end

					# Codificação NVE - Nomenclatura de Valor Aduaneiro e Estatística.
					# Codificação opcional que detalha alguns NCM.
					# Formato: duas letras maiúsculas e 4 algarismos. Se a
					# mercadoria se enquadrar em mais de uma codificação, informar
					# até 8 codificações principais. Vide: Anexo XII.03 - Identificador NVE.
					# 
					# <b>Type:     </b> _Array_
					# <b>Required: </b> _No_
					# <b>Example:  </b> _['AB12324','AB5678'] OU 'AB4567'_
					# <b>Length:   </b> _max: 8_
					#
					attr_accessor :codigos_nve
					def codigos_nve
						@codigos_nve = [@codigos_nve] unless @codigos_nve.is_a?(Array)
						@codigos_nve.flatten!
						@codigos_nve.compact!
						@codigos_nve
					end

					# Código da Tabela de Incidência do IPI - TIPI
					# Preencher de acordo com o código EX da TIPI. Em caso de
					# serviço, não incluir a TAG.
					#
					# <b>Type:     </b> _String_
					# <b>Required: </b> _No_
					# <b>Example:  </b> _123_
					# <b>Length:   </b> _min: 2, max: 3_
					#
					attr_accessor :codigo_extipi
					
					# Código Fiscal de Operações e Prestações
					# Utilizar a Tabela de CFOPs para preencher essa informação.
					#
					# OBS: esse atributo sempre vai retornar apenas os números
					#      EX: Se preencher com '5.102' vai retornar '5102'
					# 
					# <b>Type:     </b> _String_ OR _Number_
					# <b>Required: </b> _Yes_
					# <b>Example:  </b> _'5.102'_ OR _5102_
					# <b>Length:   </b> _4_
					#
					attr_accessor :cfop
					def cfop
						"#{@cfop}".gsub(/[^\d]/,'')
					end

					# Unidade Comercial
					# informar a unidade de comercialização do produto 
					# (Ex. pc, und, dz, kg, etc.).
					#
					# <b>Type:     </b> _String_
					# <b>Required: </b> _Yes_
					# <b>Example:  </b> _KG_
					# <b>Length:   </b> _max: 6_
					#
					attr_accessor :unidade_comercial

					# Quantidade Comercial
					# Informar a quantidade de comercialização do produto (v2.0).
					#
					# <b>Type:     </b> _Float_
					# <b>Required: </b> _Yes_
					# <b>Example:  </b> _2.5_
					#
					attr_accessor :quantidade_comercial

					# Valor Unitário de Comercialização
					# Informar o valor unitário de comercialização do produto, campo
					# meramente informativo, o contribuinte pode utilizar a precisão
					# desejada (0-10 decimais). Para efeitos de cálculo, o valor
					# unitário será obtido pela divisão do valor do produto pela
					# quantidade comercial. (v2.0)
					#
					# <b>Type:     </b> _Number_
					# <b>Required: </b> _Yes_
					# <b>Example:  </b> _22.5_ OU _2_
					#
					attr_accessor :valor_unitario_comercial
					def valor_unitario_comercial
						@valor_unitario_comercial ||= valor_unitario_comercial_calculation
						@valor_unitario_comercial
					end

					# Valor Total Bruto dos Produtos ou Serviços
					#
					# <b>Type:     </b> _Float_
					# <b>Required: </b> _Yes_
					# <b>Example:  </b> _3122.55_ OU _100_
					#
					attr_accessor :valor_total_produto

					# GTIN (Global Trade Item Number) da unidade tributável, 
					# antigo código EAN ou código de barras
					# Preencher com o código GTIN-8, GTIN-12, GTIN-13 ou GTIN-14 
					# (antigos códigos EAN, UPC e DUN-14) da unidade tributável
					# do produto, não informar o conteúdo da TAG em caso de o
					# produto não possuir este código.
					#
					# OBS: esse atributo sempre vai retornar apenas os números setados 
					#
					# <b>Type:     </b> _Number_
					# <b>Required: </b> _No_
					# <b>Example:  </b> _12345678_
					# <b>Length:   </b> _max: 14_
					#
					attr_accessor :codigo_ean_tributavel
					alias_attribute :codigo_gtin_tributavel, :codigo_ean_tributavel
					def codigo_ean_tributavel
						"#{@codigo_ean_tributavel}".gsub(/[^\d]/,'')
					end

					# Quantidade Tributável
					# Informar a quantidade de tributação do produto (v2.0).
					#
					# NOTA: Por termos diversos casos na legislação onde a tributação 
					#  incide em unidades de produtos diferentes da que ele é costumeiramente 
					#  vendido no mercado, especialmente no atacado. Ou seja, a unidade tributa 
					#  é diferente da unidade comercializada, por este motivo é que foram criados 
					#  os respectivos campos na NF-e (uCom, qCom e vCom)  (uTrib, qTrib e vUnTrib),  
					#  sendo que o resultado  (qCom * uCom) seja igual a (qTrib * uTrib).
					#    Tomemos como exemplo o refrigerante pet de 2 litros que tem 
					#  definido na pauta fiscal a “unidade tributável” como garrafa de 2litros, 
					#  sendo que o fabricante comercializa o mesmo produto em pacote com 6 unidades.
					#  Assim na venda de 2 pacotes, temos como unidade comercial de 2 unidades 
					#  que equivalem a 12 litros (2 x 6), com 2 litros cada.
					#  Na unidade tributável, temos também 12 unidades tributáveis (12 x 1 unidade de 2 litros).
					#    Observem que sempre qCom * uCom = qTrib * uTrib.
					#    É importante ressaltar que na maioria dos casos a unidade comercial e a 
					#  unidade tributável são iguais.
					#  Fonte: http://www.tecnospeed.com.br/forum/o-contador/motivo-da-rejeicao-nos-campos-unidade-tributave-e-unidade-comercial/
					#
					# <b>Type:     </b> _Float_
					# <b>Required: </b> _Yes_
					# <b>Example:  </b> _2.5_
					#
					attr_accessor :quantidade_tributavel
					def quantidade_tributavel
						@quantidade_tributavel ||= quantidade_comercial
					end
					# Unidade Tributável
					# Informar a unidade de tributação do produto 
					# (Ex. pc, und, dz, kg, etc.).
					#
					# <b>Type:     </b> _String_
					# <b>Required: </b> _Yes_
					# <b>Example:  </b> _KG_
					# <b>Length:   </b> _max: 6_
					#
					attr_accessor :unidade_tributavel
					def unidade_tributavel
						@unidade_tributavel ||= unidade_comercial
					end
					# Valor Unitário de tributação
					# Informar o valor unitário de tributação do produto, campo
					# meramente informativo, o contribuinte pode utilizar a precisão
					# desejada (0-10 decimais). Para efeitos de cálculo, o valor
					# unitário será obtido pela divisão do valor do produto pela
					# quantidade tributável (NT 2013/003).
					#
					# <b>Type:     </b> _Number_
					# <b>Required: </b> _Yes_
					# <b>Example:  </b> _22.5_ OU _2_
					#
					attr_accessor :valor_unitario_tributavel
					def valor_unitario_tributavel
						@valor_unitario_tributavel ||= valor_unitario_tributavel_calculation
						@valor_unitario_tributavel
					end

					# Valor Total do Frete
					#
					# <b>Type:     </b> _Number_
					# <b>Required: </b> _No_
					# <b>Example:  </b> _22.5_ OU _2_
					#
					attr_accessor :total_frete

					# Valor Total do Seguro
					#
					# <b>Type:     </b> _Number_
					# <b>Required: </b> _No_
					# <b>Example:  </b> _22.5_ OU _2_
					#
					attr_accessor :total_seguro

					# Valor do Desconto
					#
					# <b>Type:     </b> _Number_
					# <b>Required: </b> _No_
					# <b>Example:  </b> _22.5_ OU _2_
					#
					attr_accessor :total_desconto

					# Outras despesas acessórias
					#
					# <b>Type:     </b> _Number_
					# <b>Required: </b> _No_
					# <b>Example:  </b> _22.5_ OU _2_
					#
					attr_accessor :total_outros

					# Indica se valor do Item (vProd) entra no valor total da NF-e (vProd)
					#   0=Valor do item (vProd) não compõe o valor total da NF-e
					#   1=Valor do item (vProd) compõe o valor total da NF-e (vProd)
					#   (v2.0)
					#
					# Informar true ou false
					#   true  = 1 (compõe o valor total da NF-e)
					#   false = 0 (NÃO compõe o valor total da NF-e)
					#
					# <b>Type:     </b> _Boolean_
					# <b>Required: </b> _Yes_
					# <b>Example:  </b> _true_
					# <b>Default:  </b> _true_
					#
					attr_accessor :soma_total_nfe

					# Código CEST
					# Código Especificador da Substituição Tributária – CEST, que
					# estabelece a sistemática de uniformização e identificação das
					# mercadorias e bens passíveis de sujeição aos regimes de
					# substituição tributária e de antecipação de recolhimento do
					# ICMS
					#
					# <b>Type:     </b> _Number_
					# <b>Required: </b> _No_
					# <b>Example:  </b> _1234567_
					# <b>Length:   </b> _7_
					#
					attr_accessor :codigo_cest


				def default_values
					{
						tipo_produto:   :product,
						soma_total_nfe: true,
					}
				end

				validates :tipo_produto, presence: true
				validates :tipo_produto, inclusion: {in: [:product, :service, :other]}

				validates :codigo_produto,    length: {maximum: 60}
				validates :codigo_ean,        length: {maximum: 14}
				validates :descricao_produto, length: {maximum: 120}

				validates :codigo_ncm, presence: true
				validates :codigo_ncm, length: {maximum: 8}, allow_blank: true, if:     :is_product?
				validates :codigo_ncm, length: {maximum: 2}, allow_blank: true, unless: :is_product?
				
				validates :codigos_nve, length: {maximum: 8}
				
				validates :codigo_extipi, length: {in: 2..3}, allow_blank: true
				
				validates :unidade_comercial, presence: true
				validates :unidade_comercial, length: {maximum: 6}, allow_blank: true
				validates :quantidade_comercial,     presence:     true
				validates :quantidade_comercial,     numericality: true
				validates :valor_unitario_comercial, presence:     true
				validates :valor_unitario_comercial, numericality: true
				validates :valor_total_produto,    presence:     true
				validates :valor_total_produto,    numericality: true

				validates :codigo_ean_tributavel,     length: {maximum: 14}
				validates :quantidade_tributavel,     presence: true
				validates :quantidade_tributavel,     numericality: true
				validates :unidade_tributavel,        presence: true
				validates :unidade_tributavel,        length: {maximum: 6}, allow_blank: true
				validates :valor_unitario_tributavel, presence: true
				validates :valor_unitario_tributavel, numericality: true
				
				validates :total_frete,    numericality: true, allow_blank: true
				validates :total_seguro,   numericality: true, allow_blank: true
				validates :total_desconto, numericality: true, allow_blank: true
				validates :total_outros,   numericality: true, allow_blank: true
				
				validates :codigo_cest,    length: {maximum: 7}

				def is_product?
					tipo_produto == :product
				end
			private

				#####################################################################
				############################# CÁLCULOS ##############################
					def valor_unitario_comercial_calculation
						(valor_total_produto.to_f/quantidade_comercial.to_f).round(10) if quantidade_comercial.to_f > 0
					end
					def valor_unitario_tributavel_calculation
						(valor_total_produto.to_f/quantidade_tributavel.to_f).round(10) if quantidade_tributavel.to_f > 0
					end

			end
		end
	end
end